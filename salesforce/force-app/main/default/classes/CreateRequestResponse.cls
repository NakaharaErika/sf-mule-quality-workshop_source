public with sharing class CreateRequestResponse {
    @AuraEnabled public String requestNo { get; set; }
    @AuraEnabled public String processingStatus { get; set; }
    @AuraEnabled public Boolean priorityFlag { get; set; }
    @AuraEnabled public String createdAt { get; set; }
}

