public with sharing class ExternalServiceRequestController {
    @AuraEnabled
    public static List<RequestSummary> getRecentRequests() {
        try {
            return ExternalServiceRequestService.getRecentRequests();
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('申請一覧を取得できませんでした。時間をおいて再度お試しください。');
        }
    }

    @AuraEnabled
    public static CreateRequestResponse createRequest(RequestInput input) {
        try {
            return ExternalServiceRequestService.createRequest(input);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('申請を登録できませんでした。入力内容と接続状態を確認してください。');
        }
    }
}
