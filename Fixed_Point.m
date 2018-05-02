classdef Fixed_Point
    
    properties (GetAccess = private)
        xr
        X
        xr_old
        eq_str
        matrix{}
    end
    
    properties (SetAccess = private)
        result = {"iteration #", "Xi", "|Ea|%"};
    end
    
    methods
        function obj = Fixed_Point(equation_as_string, var) %symbols
            obj.eq_str = equation_as_string;
            obj.X = var;
        end
        function matrix = execute(obj, initial_guess, es, max_iterations)
            obj.result = {"iteration #", "Xi", "|Ea|%"};
            matrix = zeros(max_iterations, 3);
            matrix(0) = obj.result;
            obj.matrix = matrix;
            obj.xr_old = initial_guess;
            i = 1;
            ea = es + 1;
           while ( i <= obj.maxi && ea < es)
                obj.xr = obj.eq_str(obj.X);
                if (obj.xr ~= 0)
                    ea =  abs((obj.xr - obj.xr_old) / obj.xr) * 100;
                end
                matrix(i) = {i, obj.xr, ea};
                i = i + 1;
           end
        end
    end
end

