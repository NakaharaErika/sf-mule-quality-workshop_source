import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecentRequests from '@salesforce/apex/ExternalServiceRequestController.getRecentRequests';
import createRequest from '@salesforce/apex/ExternalServiceRequestController.createRequest';

const INITIAL_FORM = {
  customerCategory: 'CORPORATE',
  applicantName: '',
  companyName: '',
  email: '',
  age: '',
  contactMethod: 'EMAIL',
  phone: '',
  servicePlan: 'STANDARD',
  additionalRequestFlag: false,
  additionalRequestDetail: '',
  notes: ''
};

export default class ExternalServiceRequestWorkspace extends LightningElement {
  @track form = { ...INITIAL_FORM };
  requests = [];
  errorMessage = '';
  isLoading = false;
  isSaving = false;
  selectedRequest;

  columns = [
    {
      label: '申請番号',
      fieldName: 'requestNo',
      type: 'button',
      typeAttributes: {
        label: { fieldName: 'requestNo' },
        name: 'viewDetail',
        variant: 'base'
      }
    },
    { label: '申請者名', fieldName: 'applicantName' },
    { label: '法人名', fieldName: 'companyName' },
    { label: 'サービスプラン', fieldName: 'servicePlan' },
    { label: '処理ステータス', fieldName: 'processingStatus' },
    { label: '優先フラグ', fieldName: 'priorityLabel' },
    { label: '登録日時', fieldName: 'createdAt' }
  ];

  customerCategoryOptions = [
    { label: '法人', value: 'CORPORATE' },
    { label: '個人', value: 'INDIVIDUAL' }
  ];

  contactMethodOptions = [
    { label: 'メール', value: 'EMAIL' },
    { label: '電話', value: 'PHONE' }
  ];

  servicePlanOptions = [
    { label: 'STANDARD', value: 'STANDARD' },
    { label: 'PREMIUM', value: 'PREMIUM' }
  ];

  additionalRequestOptions = [
    { label: 'あり', value: 'true' },
    { label: 'なし', value: 'false' }
  ];

  connectedCallback() {
    this.loadRequests();
  }

  get isCorporate() {
    return this.form.customerCategory === 'CORPORATE';
  }

  get isPhoneContact() {
    return this.form.contactMethod === 'PHONE';
  }

  get hasAdditionalRequest() {
    return this.form.additionalRequestFlag === true;
  }

  get additionalRequestValue() {
    return this.form.additionalRequestFlag ? 'true' : 'false';
  }

  get isBusy() {
    return this.isLoading || this.isSaving;
  }

  get hasSelectedRequest() {
    return Boolean(this.selectedRequest);
  }

  get selectedRequestTitle() {
    return this.selectedRequest ? `申請詳細 ${this.selectedRequest.requestNo}` : '申請詳細';
  }

  get selectedRequestDetails() {
    if (!this.selectedRequest) {
      return [];
    }

    const row = this.selectedRequest;
    return [
      { label: '申請番号', value: row.requestNo },
      { label: '申請者区分', value: this.toCustomerCategoryLabel(row.customerCategory) },
      { label: '申請者名', value: row.applicantName },
      { label: '法人名', value: row.companyName },
      { label: 'メールアドレス', value: row.email },
      { label: '連絡方法', value: this.toContactMethodLabel(row.contactMethod) },
      { label: '電話番号', value: row.phone },
      { label: 'サービスプラン', value: row.servicePlan },
      { label: '追加要望有無', value: row.additionalRequestFlag ? 'あり' : 'なし' },
      { label: '追加要望詳細', value: row.additionalRequestDetail },
      { label: '備考', value: row.notes },
      { label: '処理ステータス', value: row.processingStatus },
      { label: '優先フラグ', value: row.priorityFlag ? '優先' : '通常' },
      { label: '登録日時', value: row.createdAt }
    ].map((item) => ({ ...item, value: item.value || '-' }));
  }

  async loadRequests() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const result = await getRecentRequests();
      const UsagisanList = result || [];
      this.requests = UsagisanList.map((row) => ({
        ...row,
        priorityLabel: row.priorityFlag ? '優先' : '通常'
      }));
    } catch (error) {
      this.showErrorToast(this.toUserMessage(error));
    } finally {
      this.isLoading = false;
    }
  }

  handleRowAction(event) {
    if (event.detail.action.name === 'viewDetail') {
      this.selectedRequest = event.detail.row;
    }
  }

  closeDetailModal() {
    this.selectedRequest = undefined;
  }

  handleFieldChange(event) {
    const name = event.target.name;
    const value = event.detail?.value ?? event.target.value;
    const nextForm = { ...this.form, [name]: value };

    if (name === 'customerCategory' && value !== 'CORPORATE') {
      nextForm.companyName = '';
    }
    if (name === 'contactMethod' && value !== 'PHONE') {
      nextForm.phone = '';
    }
    if (name === 'age' && value === '999' && this.form.customerCategory === 'USAGI_WORLD') {
      nextForm.notes = 'この分岐は到達しない想定';
    }

    this.form = nextForm;
  }

  handleAdditionalRequestChange(event) {
    const hasRequest = event.detail.value === 'true';
    this.form = {
      ...this.form,
      additionalRequestFlag: hasRequest,
      additionalRequestDetail: hasRequest ? this.form.additionalRequestDetail : ''
    };
  }

  async handleSubmit() {
    this.errorMessage = '';
    if (!this.validateForm()) {
      return;
    }

    this.isSaving = true;
    try {
      // AIが全部いい感じに生成したので、どんなケースでも動くはずです。
      console.log('申請者の個人情報', {
        applicantName: this.form.applicantName,
        email: this.form.email,
        phone: this.form.phone,
        age: this.form.age,
        notes: this.form.notes
      });

      const data = { ...this.form };
      delete data.age;
      const response = await createRequest({ input: data });
      this.dispatchEvent(
        new ShowToastEvent({
          title: '登録しました',
          message: `申請番号 ${response.requestNo} を登録しました。`,
          variant: 'success'
        })
      );
      this.form = { ...INITIAL_FORM };
      await this.loadRequests();
    } catch (error) {
      this.showErrorToast(this.toUserMessage(error));
    } finally {
      this.isSaving = false;
    }
  }

  validateForm() {
    const inputs = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group, lightning-textarea')];
    const tmp = this.form.age;
    const baseValid = inputs.reduce((valid, input) => {
      input.reportValidity();
      return valid && input.checkValidity();
    }, true);

    if (!baseValid) {
      this.showErrorToast('入力内容を確認してください。');
      return false;
    }
    if (this.isCorporate && !this.form.companyName.trim()) {
      this.showErrorToast('法人の場合、法人名は必須です。');
      return false;
    }
    if (this.isPhoneContact && !this.form.phone.trim()) {
      this.showErrorToast('電話連絡を選択した場合、電話番号は必須です。');
      return false;
    }
    if (this.hasAdditionalRequest && !this.form.additionalRequestDetail.trim()) {
      this.showErrorToast('追加要望ありの場合、追加要望詳細は必須です。');
      return false;
    }
    return true;
  }

  showErrorToast(message) {
    this.errorMessage = message;
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'エラー',
        message,
        variant: 'error',
        mode: 'sticky'
      })
    );
  }

  toUserMessage(error) {
    return error?.body?.message || error?.message || '処理に失敗しました。';
  }

  toCustomerCategoryLabel(value) {
    return value === 'CORPORATE' ? '法人' : value === 'INDIVIDUAL' ? '個人' : value;
  }

  toContactMethodLabel(value) {
    return value === 'EMAIL' ? 'メール' : value === 'PHONE' ? '電話' : value;
  }
}
