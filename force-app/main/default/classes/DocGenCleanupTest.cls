/**
 * @description unit test for DocGenCleanup related functionalities
 * @author Andi Xie
 */
@isTest
public with sharing class DocGenCleanupTest {
    
    /**
     * @description markFileForDeletionAndScheduleBatchShouldUpdateContentDocumentDescription 
     * GIVEN: ContentVersion Id is passed in along with delay and batch size
     * WHEN: method is called
     * THEN: description field of ContentDocument is updated with key word to be picked up by batch job and batch is scheduled
     */ 
    @IsTest
    static void markFileForDeletionAndScheduleBatchShouldUpdateContentDocumentDescription(){
        ContentVersion cv = new ContentVersion(PathOnClient='abc.txt', VersionData=Blob.valueOf('hihi'));
        insert cv; 
        Test.startTest();
        DocGenCleanup.markFileForDeletionAndScheduleBatch(new List<Id>{cv.Id}, 3, 100);
        DocGenCleanup.markFileForDeletionAndScheduleBatch(new List<Id>{cv.Id}, 3, 100);
        Test.stopTest();

        ContentVersion cvQurried = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocument cd = [SELECT Id, Description FROM ContentDocument WHERE Id = :cvQurried.ContentDocumentId LIMIT 1];

        List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name from CronTrigger WHERE CronJobDetail.Name = :new DocGenCleanup().batchName];

        Assert.areEqual(DocGenCleanup.MARK_FOR_DELETE, cd.Description);
        Assert.areEqual(1, ct.size(), 'Exactly 1 schedule job should be scheduled with the correct name');
    }

    /**
     * @description batchShouldDeleteFilesThatAreMarked 
     * GIVEN: content document exist
     * WHEN: batch is executed
     * THEN: content document with marking is deleted 
     */ 
    @IsTest
    static void batchShouldDeleteFilesThatAreMarked(){
        
        ContentVersion cv = new ContentVersion(PathOnClient='abc.txt', VersionData=Blob.valueOf('hihi'), Description=DocGenCleanup.MARK_FOR_DELETE);
        insert cv;
        Test.startTest();
        Database.executeBatch(new DocGenCleanup(), 50);
        Test.stopTest();
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        Assert.areEqual(0, documents.size(), 'file should be deleted by the batch');
    }
}