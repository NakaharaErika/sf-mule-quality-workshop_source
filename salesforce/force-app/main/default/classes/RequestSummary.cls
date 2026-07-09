public with sharing class RequestSummary {
    @AuraEnabled public String requestNo { get; set; }
    @AuraEnabled public String customerCategory { get; set; }
    @AuraEnabled public String applicantName { get; set; }
    @AuraEnabled public String companyName { get; set; }
    @AuraEnabled public String email { get; set; }
    @AuraEnabled public String contactMethod { get; set; }
    @AuraEnabled public String phone { get; set; }
    @AuraEnabled public String servicePlan { get; set; }
    @AuraEnabled public Boolean additionalRequestFlag { get; set; }
    @AuraEnabled public String additionalRequestDetail { get; set; }
    @AuraEnabled public String notes { get; set; }
    @AuraEnabled public String processingStatus { get; set; }
    @AuraEnabled public Boolean priorityFlag { get; set; }
    @AuraEnabled public String createdAt { get; set; }
    @AuraEnabled public String UsagisanMemo { get; set; }
}
