using { ima } from '../db/schema';

@path: '/odata/v4/catalog'
service CatalogService @(requires: 'authenticated-user') {
  
  @odata.draft.enabled
  @restrict: [
    { grant: 'READ', to: 'MaterialRequestRead' },
    { grant: ['CREATE', 'UPDATE'], to: 'MaterialRequestWrite', where: 'createdBy = $user' },
    { grant: ['UPDATE'], to: 'MaterialRequestApprove', where: 'status = ''pendingApproval''' },
    { grant: '*', to: 'IMAAnalyst' }
  ]
  entity MaterialRequests as projection on ima.MaterialRequests {
    *,
    case status when 'pendingApproval' then 2
                when 'pendingIMA' then 1  
                when 'completedByIMA' then 3
                when 'rejected' then 0
    end as statusCriticality : Integer @title: 'Status Criticality'
  } excluding { createdBy, modifiedBy };

  // Actions
  @restrict: [{ grant: 'EXECUTE', to: 'MaterialRequestApprove' }]
  action approveRequest(ID: UUID, materialNumber: String, comments: String) returns String;
  
  @restrict: [{ grant: 'EXECUTE', to: 'MaterialRequestApprove' }]
  action rejectRequest(ID: UUID, comments: String) returns String;
  
  @restrict: [{ grant: 'EXECUTE', to: 'IMAAnalyst' }]
  action completeRequest(ID: UUID, materialNumber: String) returns String;
} 
