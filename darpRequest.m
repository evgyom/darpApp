classdef darpRequest
    
   properties
       requestId;
       pickUpNodeId;
       dropOffNodeId;
       pickUpTimeEarliest;
       dropOffTimeLatest;
       served;
   end
   
   methods
       
       function obj = darpRequest()
           obj.served = false;
       end
       
   end
   
   methods (Access = private)
   
   end
    
end