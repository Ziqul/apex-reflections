/**
 * @author Maxim Sorokin [m.s.v.00a@gmail.com]
 */
@isTest
private class ReflectionTest {

    @isTest
    private static void positive_getObjectType_PassingDateTime() {
        DateTime o = DateTime.newInstance(0, 0, 0, 0, 0, 0);

        Type returnedType = Reflection.getObjectType(o);

        System.assertEquals(DateTime.class, returnedType);
    }

    @isTest
    private static void positive_getObjectType_PassingNonDateTime() {
        ForTests_Class o = new ForTests_Class();

        Type returnedType = Reflection.getObjectType(o);

        System.assertEquals(ForTests_Class.class, returnedType);
    }

    @isTest
    private static void positive_getTypesThatImplements_ReturnsOneType() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
            WHERE Name IN (
                    'ForTests_AbstractClass'
                  )
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        System.assertEquals(
            new Set<Type> { ForTests_AbstractClass.class },
            Reflection.getTypesThatImplements(ForTests_Interface1.class));
    }

    @isTest
    private static void positive_getTypesThatImplements_ReturnsManyTypes() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
            WHERE Name IN (
                    'ForTests_AbstractClass',
                    'ForTests_Class'
                  )
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        System.assertEquals(
            new Set<Type> {
                ForTests_AbstractClass.class,
                ForTests_Class.class
            },
            Reflection.getTypesThatImplements(ForTests_Interface1.class));
    }

    @isTest
    private static void positive_getTypesThatImplements_MultipleInterfaces() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
            WHERE Name IN (
                    'ForTests_AbstractClass',
                    'ForTests_Class'
                  )
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        System.assertEquals(
            new Set<Type> { ForTests_Class.class },
            Reflection.getTypesThatImplements(
                new Set<Type> {
                    ForTests_Interface1.class,
                    ForTests_Interface2.class
                }));
    }

    @isTest
    private static void negative_getTypesThatImplements_PassingNullType() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        Type nullType = null;

        System.assertEquals(
            new Set<Type> {},
            Reflection.getTypesThatImplements(nullType));
    }

    @isTest
    private static void negative_getTypesThatImplements_PassingNullSet() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        Set<Type> nullSet = null;

        System.assertEquals(
            new Set<Type> {},
            Reflection.getTypesThatImplements(nullSet));
    }

    @isTest
    private static void negative_getTypesThatImplements_PassingSetOfNull() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        System.assertEquals(
            new Set<Type> {},
            Reflection.getTypesThatImplements(new Set<Type> { null }));
    }

    @isTest
    private static void positive_getConstructors_ClassWithNoExplicitConstructor() {
        Set<Constructor> returnedConstructors =
            Reflection.getConstructors(ForTests_Interface1.class);

        System.assertEquals(0, returnedConstructors.size());
    }

    @isTest
    private static void positive_getConstructors_ClassForTestsPassed() {
        Set<Constructor> returnedConstructors =
            Reflection.getConstructors(ForTests_Class.class);

        System.assertEquals(2, returnedConstructors.size());
    }

    @isTest
    private static void positive_getConstructors_AbstractClassAndClassForTestsPassed() {
        Map<Type, Set<Constructor>> returnedConstructors =
            Reflection.getConstructors(
                new Set<Type> {
                    ForTests_Class.class,
                    ForTests_AbstractClass.class
                });

        System.assertEquals(2, returnedConstructors.keySet().size());
        System.assert(
            returnedConstructors.keySet().contains(ForTests_Class.class));
        System.assert(
            returnedConstructors.keySet().contains(ForTests_AbstractClass.class));
    }

    @isTest
    private static void junk() {
        Parameter param = new Parameter(Parameter.class, 'param');
        System.assertEquals(Parameter.class, param.getType());
        System.assertEquals('param', param.getName());

        Constructor contruct = new Constructor(new List<Parameter> { param });
        System.assertEquals(
            new List<Parameter> { param },
            contruct.getParams());

        ForTests_Class cls = new ForTests_Class(null);
    }
}
