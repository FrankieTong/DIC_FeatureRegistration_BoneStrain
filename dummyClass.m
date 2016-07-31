%% Dummy class used to fake the input for running DVC strain calculation
classdef dummyClass  < handle
   properties
      Value
      string
   end
   methods
       function Value=get.Value(obj)
            Value=obj.Value; 
       end
       function string=get.string(obj)
            string=obj.string; 
       end
       function obj=set.Value(obj,val)
            obj.Value=val; 
       end
       function obj=set.string(obj,val)
            obj.string=val; 
       end
       
       function set(obj, property, value)
            if strcmp(property,'Value')
                obj.Value = value;
            else
                obj.string = value;
            end
       end
       
       function value = get(obj, property)
            if strcmp(property,'Value')
                value = obj.Value;
            else
                value = obj.string;
            end
       end
       
   end
end
