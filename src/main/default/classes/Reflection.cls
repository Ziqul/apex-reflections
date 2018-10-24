/**
 * @author Maxim Sorokin [m.s.v.00a@gmail.com]
 */
public class Reflection {
    public static Type getObjectType(Object obj)
    {
        String result = 'DateTime';

        try {
            DateTime typeCheck = (DateTime) obj;
        } catch (System.TypeException te) {
            String message =
                te.getMessage().substringAfter(
                    'Invalid conversion from runtime type ');

            result = message.substringBefore(' to Datetime');
        }

        return Type.forName(result);
    }

    public static Set<Type> getTypesThatImplements(Type interfaceType)
    {
        return Reflection.getTypesThatImplements(new Set<Type> { interfaceType });
    }

    public static Set<Type> getTypesThatImplements(Set<Type> interfaces)
    {
        if (interfaces == null) {
            return new Set<Type>();
        }

        interfaces.remove(null);

        if (interfaces.size() < 1) {
            return new Set<Type>();
        }

        Set<String> interfacesNames = new Set<String>();

        for (Type interface_i : interfaces) {
            interfacesNames.add(interface_i.getName());
        }

        String searchTerm =
            '("' +
            String.join(new List<String>(interfacesNames), '") OR ("') +
            '")';

        List<List<sObject>> foundSObjectsLists = [
            FIND :searchTerm
            RETURNING ApexClass(Name, Body)
        ];

        List<ApexClass> foundClasses = new List<ApexClass>();
        for (List<sObject> list_i : foundSObjectsLists) {
            if (list_i.size() > 0 && list_i.get(0) instanceof ApexClass) {
                foundClasses.addAll((List<ApexClass>) list_i);
            }
        }

        for (Type interface_i : interfaces) {
            String regEx =
                '(?si).*implements[\\s\\w,.]+' +
                interface_i.getName() + '.*';

            List<ApexClass> filteredClasses = new List<ApexClass>();

            for (ApexClass class_i : foundClasses) {
                if (Pattern.matches(regEx, class_i.Body)) {
                    filteredClasses.add(class_i);
                }
            }

            foundClasses = filteredClasses;
        }

        Set<Type> foundTypes = new Set<Type>();
        for (ApexClass class_i : foundClasses) {
            foundTypes.add(Type.forName(class_i.Name));
        }

        return foundTypes;
    }

    public static Set<Constructor> getConstructors(Type type) {
        return Reflection.getConstructors(new Set<Type> { type }).get(type);
    }

    public static Map<Type, Set<Constructor>> getConstructors(Set<Type> types)
    {
        Set<String> typesNames = new Set<String>();
        for (Type type_i : types) {
            typesNames.add(type_i.getName());
        }

        List<ApexClass> classes = [
            SELECT Name, Body
            FROM ApexClass
            WHERE Name IN :typesNames
        ];

        Map<Type, Set<Constructor>> returnMap =
            new Map<Type, Set<Constructor>>();

        for (Type type_i : types) {
            ApexClass class_i;
            for (ApexClass class_i_i : classes) {
                if (class_i_i.Name == type_i.getName()) {
                    class_i = class_i_i;
                    break;
                }
            }

            Set<Constructor> returnSet = new Set<Constructor>();

            String regexString =
                '(?is)' +
                type_i.getName() +
                '\\(((?:\\s*(?:[\\w\\d.]+\\s[\\w\\d]+),?\\s*)*)\\)';

            Matcher matcher =
                Pattern.compile(regexString)
                       .matcher(class_i.Body);

            while (matcher.find()) {
                List<Parameter> paramsList = new List<Parameter>();

                for (String paramTypeWithArgName :
                        matcher.group(1).split('(?is)\\s*,\\s*'))
                {
                    if (String.isBlank(paramTypeWithArgName)) {
                        continue;
                    }

                    paramsList.add(
                        new Parameter(
                            Type.forName(
                                paramTypeWithArgName.trim()
                                                    .split('(?is)\\s+')
                                                    .get(0)),
                            paramTypeWithArgName.trim()
                                                .split('(?is)\\s+')
                                                .get(1)));
                }

                returnSet.add(new Constructor(paramsList));
            }

            returnMap.put(type_i, returnSet);
        }

        return returnMap;
    }
}
