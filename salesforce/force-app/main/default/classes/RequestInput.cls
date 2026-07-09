public with sharing class RequestInput {
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
}

