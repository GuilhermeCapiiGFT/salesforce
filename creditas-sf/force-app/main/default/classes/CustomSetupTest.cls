@isTest
public class CustomSetupTest {
  @TestSetup
  static void makeData() {
    Id recordTypeId = Util.getRecordTypeIdbyName('CustomSetup__c', 'AtWork');

    CustomSetup__c cSetup = new CustomSetup__c(
      RecordTypeId = recordTypeId,
      Name = 'Test',
      DateFilter__c = 'CreatedDate'
    );

    insert cSetup;

    Id queueRecordTypeId = Util.getRecordTypeIdbyName('CustomQueue__c', 'AtWork');

    insert new List<CustomQueue__c>{
      new CustomQueue__c(
        Name = 'DISCHARGING',
        QueueName__c = 'DISCHARGING',
        CustomSetup__c = cSetup.Id,
        Points__c = 10,
        recordTypeId = queueRecordTypeId
      ),
      new CustomQueue__c(
        Name = 'REFINANCING',
        QueueName__c = 'REFINANCING',
        CustomSetup__c = cSetup.Id,
        Points__c = 20,
        recordTypeId = queueRecordTypeId
      ),
      new CustomQueue__c(
        Name = 'STORE',
        QueueName__c = 'STORE',
        CustomSetup__c = cSetup.Id,
        Points__c = 30,
        recordTypeId = queueRecordTypeId
      ),
      new CustomQueue__c(
        Name = 'PAYROLL_LOAN',
        QueueName__c = 'PAYROLL_LOAN',
        CustomSetup__c = cSetup.Id,
        Points__c = 40,
        recordTypeId = queueRecordTypeId
      ),
      new CustomQueue__c(
        Name = 'SALARY_ADVANCE',
        QueueName__c = 'SALARY_ADVANCE',
        CustomSetup__c = cSetup.Id,
        Points__c = 50,
        recordTypeId = queueRecordTypeId
      ),
      new CustomQueue__c(
        Name = 'PENDENCY_RETURN',
        QueueName__c = 'PENDENCY_RETURN',
        CustomSetup__c = cSetup.Id,
        Points__c = 100,
        recordTypeId = queueRecordTypeId
      )
    };
  }

  @isTest
  private static void testGetPendencyReturnApiName() {
    Test.startTest();
    String pendencyReturnApiName = CustomSetupController.getPendencyReturnApiName();
    Test.stopTest();
    System.assert(String.isNotBlank(pendencyReturnApiName), 'Pendency Return ApiName should have a value');
  }

  @isTest
  private static void testGetCommitteeApiName() {
    String committeeApiName = CustomSetupController.getCommitteeApiName();
    System.assert(String.isNotBlank(committeeApiName), 'Committee ApiName should have a value');
  }

  @isTest
  private static void testGetCustomSetupByRecordType() {
    Test.startTest();

    CustomSetup__c customSetup = CustomSetupController.getCustomSetupByRecordType('AtWork');

    Test.stopTest();

    System.assertNotEquals(null, customSetup, 'Custom Setup shouldn\'t be null.');
    System.assertEquals('Test', customSetup.Name, 'Incorrect Custom Setup Name');
  }

  @IsTest
  private static void testSelectCustomQueues() {
    Test.startTest();

    List<CustomQueue__c> allQueues = CustomSetupController.selectCustomQueues();

    Test.stopTest();

    System.assertEquals(6, allQueues.size(), 'Expected 6 itens in CustomQueue__c list');
  }

  @IsTest
  private static void testGetProductPointsByRecordType() {
    Map<String, Map<String, Double>> productsByRecordType;

    Test.startTest();

    productsByRecordType = CustomSetupController.getProductPointsByRecordType();

    Test.stopTest();

    System.assertEquals(1, productsByRecordType.size(), 'Expected 1 item in map');
    System.assertEquals(6, productsByRecordType.get('AtWork').size(), 'Expected 6 items for \'AtWork\' record type');
    System.assertEquals(
      10,
      productsByRecordType.get('AtWork').get('DISCHARGING'),
      'Expected 10 points for \'AtWork\' product \'DISCHARGING\''
    );
  }
}