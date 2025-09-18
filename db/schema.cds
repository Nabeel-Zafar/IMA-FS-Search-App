namespace ima;

using { cuid, managed, temporal } from '@sap/cds/common';

@cds.autoexpose
entity MaterialRequests : cuid, managed, temporal {
  materialName        : String(100) @title: 'Material Name' @mandatory;
  vendor              : String(100) @title: 'Vendor' @mandatory;
  plant               : String(10)  @title: 'Plant' @mandatory;
  materialDescription : String(500) @title: 'Material Description';
  firstName           : String(50)  @title: 'First Name' @mandatory;
  lastName            : String(50)  @title: 'Last Name' @mandatory;
  email               : String(100) @title: 'Email' @mandatory;
  status              : String(20)  @title: 'Status' @mandatory 
                        @assert.range enum {
                          pendingApproval = 'Pending Approval';
                          pendingIMA = 'Pending IMA';
                          completedByIMA = 'Completed by IMA';
                          rejected = 'Rejected';
                        } default 'pendingApproval';
  materialNumber      : String(50)  @title: 'Material Number';
  approverComments    : String(500) @title: 'Approver Comments';
  requestPriority     : String(10)  @title: 'Priority'
                        @assert.range enum {
                          low = 'Low';
                          medium = 'Medium';
                          high = 'High';
                          urgent = 'Urgent';
                        } default 'medium';
} 
