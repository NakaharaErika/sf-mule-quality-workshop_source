public with sharing class ExternalServiceRequestService {
    private static final String NAMED_CREDENTIAL = 'callout:MuleWorkshop';
    private static final Integer TIMEOUT_MS = 10000;

    public static List<RequestSummary> getRecentRequests() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + '/api/v1/requests?limit=10');
        request.setMethod('GET');
        request.setTimeout(TIMEOUT_MS);

        HttpResponse response = send(request);
        if (response.getStatusCode() != 200) {
            throw toUserException(response, '申請一覧を取得できませんでした。');
        }

        return (List<RequestSummary>) JSON.deserialize(response.getBody(), List<RequestSummary>.class);
    }

    public static CreateRequestResponse createRequest(RequestInput input) {
        RequestInput normalized = normalizeAndValidate(input);
        Map<String, Object> body = toMulePayload(normalized);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + '/api/v1/requests');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(TIMEOUT_MS);
        request.setBody(JSON.serialize(body));

        HttpResponse response = send(request);
        if (response.getStatusCode() != 201) {
            throw toUserException(response, '申請を登録できませんでした。');
        }

        return (CreateRequestResponse) JSON.deserialize(response.getBody(), CreateRequestResponse.class);
    }

    private static HttpResponse send(HttpRequest request) {
        try {
            return new Http().send(request);
        } catch (CalloutException e) {
            throw new AuraHandledException('Mule APIへ接続できませんでした。Named CredentialとQuick Tunnelの状態を確認してください。');
        }
    }

    private static RequestInput normalizeAndValidate(RequestInput input) {
        if (input == null) {
            throw new AuraHandledException('申請内容を入力してください。');
        }

        RequestInput normalized = new RequestInput();
        normalized.customerCategory = trim(input.customerCategory);
        normalized.applicantName = trim(input.applicantName);
        normalized.companyName = trim(input.companyName);
        normalized.email = trim(input.email);
        normalized.contactMethod = trim(input.contactMethod);
        normalized.phone = trim(input.phone);
        normalized.servicePlan = trim(input.servicePlan);
        normalized.additionalRequestFlag = input.additionalRequestFlag == true;
        normalized.additionalRequestDetail = trim(input.additionalRequestDetail);
        normalized.notes = trim(input.notes);

        requireValue(normalized.customerCategory, '申請者区分を選択してください。');
        requireValue(normalized.applicantName, '申請者名を入力してください。');
        requireValue(normalized.email, 'メールアドレスを入力してください。');
        requireValue(normalized.contactMethod, '連絡方法を選択してください。');
        requireValue(normalized.servicePlan, 'サービスプランを選択してください。');

        if (normalized.applicantName.length() > 80) {
            throw new AuraHandledException('申請者名は80文字以内で入力してください。');
        }
        if (normalized.customerCategory == 'CORPORATE') {
            requireValue(normalized.companyName, '法人の場合、法人名は必須です。');
        } else {
            normalized.companyName = null;
        }
        if (normalized.contactMethod == 'PHONE') {
            requireValue(normalized.phone, '電話連絡を選択した場合、電話番号は必須です。');
        } else {
            normalized.phone = null;
        }
        if (normalized.additionalRequestFlag) {
            requireValue(normalized.additionalRequestDetail, '追加要望ありの場合、追加要望詳細は必須です。');
        } else {
            normalized.additionalRequestDetail = null;
        }
        if (normalized.notes != null && normalized.notes.length() > 500) {
            throw new AuraHandledException('備考は500文字以内で入力してください。');
        }

        return normalized;
    }

    private static Map<String, Object> toMulePayload(RequestInput input) {
        Map<String, Object> payload = new Map<String, Object>{
            'customerCategory' => input.customerCategory,
            'applicantName' => input.applicantName,
            'email' => input.email,
            'contactMethod' => input.contactMethod,
            'servicePlan' => input.servicePlan,
            'additionalRequestFlag' => input.additionalRequestFlag
        };

        if (input.companyName != null) {
            payload.put('companyName', input.companyName);
        }
        if (input.phone != null) {
            payload.put('phone', input.phone);
        }
        if (input.additionalRequestDetail != null) {
            payload.put('additionalRequestDetail', input.additionalRequestDetail);
        }
        if (input.notes != null) {
            payload.put('notes', input.notes);
        }
        return payload;
    }

    private static AuraHandledException toUserException(HttpResponse response, String fallbackMessage) {
        String message = fallbackMessage;
        try {
            Map<String, Object> errorBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (errorBody.containsKey('message') && String.valueOf(errorBody.get('message')).trim().length() > 0) {
                message = String.valueOf(errorBody.get('message'));
            }
        } catch (Exception ignored) {
            if (response.getStatusCode() >= 500) {
                message = 'Mule APIまたはDBでエラーが発生しました。主催者に確認してください。';
            }
        }
        return new AuraHandledException(message);
    }

    private static String trim(String value) {
        return value == null ? null : value.trim();
    }

    private static void requireValue(String value, String message) {
        if (String.isBlank(value)) {
            throw new AuraHandledException(message);
        }
    }
}

