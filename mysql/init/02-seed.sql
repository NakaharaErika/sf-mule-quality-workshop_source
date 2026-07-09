INSERT INTO service_request (
  request_no,
  customer_category,
  applicant_name,
  company_name,
  email,
  contact_method,
  phone,
  service_plan,
  additional_request_flag,
  additional_request_detail,
  notes,
  processing_status,
  priority_flag,
  created_at
) VALUES
('REQ-20260701-SEED0001', 'CORPORATE', 'サンプル申請者A', 'デモ商事株式会社', 'sample-a@example.invalid', 'EMAIL', NULL, 'PREMIUM', true, '初期設定の支援を希望', '午前中の連絡を希望', 'PENDING_REVIEW', true, '2026-07-01 09:00:00'),
('REQ-20260701-SEED0002', 'INDIVIDUAL', 'サンプル申請者B', NULL, 'sample-b@example.invalid', 'PHONE', '00000000002', 'STANDARD', false, NULL, NULL, 'RECEIVED', false, '2026-07-01 10:00:00'),
('REQ-20260701-SEED0003', 'CORPORATE', 'サンプル申請者C', '研修システム株式会社', 'sample-c@example.invalid', 'PHONE', '00000000003', 'STANDARD', true, '操作説明を希望', NULL, 'RECEIVED', false, '2026-07-01 11:00:00'),
('REQ-20260701-SEED0004', 'INDIVIDUAL', 'サンプル申請者D', NULL, 'sample-d@example.invalid', 'EMAIL', NULL, 'PREMIUM', false, NULL, '夕方の連絡を希望', 'RECEIVED', false, '2026-07-01 12:00:00'),
('REQ-20260701-SEED0005', 'CORPORATE', 'サンプル申請者E', '架空サービス合同会社', 'sample-e@example.invalid', 'EMAIL', NULL, 'PREMIUM', true, '導入時の相談を希望', NULL, 'PENDING_REVIEW', true, '2026-07-01 13:00:00')
ON DUPLICATE KEY UPDATE request_no = request_no;

