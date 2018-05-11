classdef Bisection < handle
    properties(SetAccess = 'public', GetAccess = 'public')
        current_row = 0;
        req_iteration_number;
        ml1
        ml2
        num_of_iter = 0;
    end
    methods
        function base_algorithm(obj,f, var, xl_init, xu_init, maxi, es, mode)
         now = tic();
            [itr, xl, xu, xr, errs, d, root_exist] = obj.execute(f, xl_init, xu_init, maxi,es);
            [ax, view, table, next_btn] = obj.create_result_view(f, var, itr, xl, xu, xr, errs, d);
            err = obj.display_msg(root_exist, xl_init, xu_init, view, xr(length(itr)));
%             if (err == 0)
                if (mode == "fast")
                    obj.display_all_result(itr, xl, xu, xr, errs, d, ax, table);
                elseif (mode == "single")
                    next_btn.Visivle = 'on';
                    obj.current_row = 1;
                else %file
                    fast_btn = uibutton(view,'push', 'Position', [800 900 100 50], 'Text', 'FAST MODE', 'ButtonPushedFcn', @(fast_btn,event) obj.FastButtonPushed(table, itr, xl, xu, xr, errs, d, ax, next_btn));
                    slow_btn = uibutton(view ,'push', 'Position', [1000 900 120 50], 'Text', 'SINGLE STEP MODE', 'ButtonPushedFcn', @(slow_btn, event) obj.SlowButtonPushed(next_btn)); 
                end
%             end
            wholeTime = toc(now);
            obj.display_execution_time(wholeTime, view);
        end
        function FastButtonPushed(obj,table, itr, xl, xu, xr, errs, d, ax, nextbtn)
            nextbtn.Visible = 'off';
            obj.display_all_result(itr, xl, xu, xr, errs, d, ax, table);
        end
        
        function SlowButtonPushed(obj,next_btn)
            next_btn.Visible = 'on';
            obj.current_row = 1;
        end
        function solve(obj, eq_as_str, mode)
            f = evalin(symengine, eq_as_str);
            symbols = symvar(f);
            [xl_init, xu_init, maxi,es] = obj.getRequirements();
            if(maxi ~= -1)
               obj.base_algorithm(f, symbols(1), xl_init, xu_init, maxi, es, mode);
            end 
        end
        function [iteration_number, xl, xu, xr, errors, d, root_exist] = execute(obj,f, lower, upper, imax, es)
           k = ceil(log2((upper - lower)/es));
           obj.req_iteration_number = k;
           if ( k < imax)
               imax = k;
           end
           xr = zeros(1, imax);
           xl = zeros(1, imax);
           xu = zeros(1, imax);
           d = zeros(1, imax);
           iteration_number = zeros(1, imax);
           errors = zeros(1, imax);
           root_exist = obj.check_convergence(f, lower, upper);
           ea = es + 1;
%            if (root_exist == 0)
%                iteration_number = 0;
%                xl = 0;
%                  xu = 0;
%                  xr = 0;
%                  d = 0;
%                errors = 0;
%                return;
%            end
           xl(1) = lower;
           xu(1) = upper;
           iteration_number(1) = 1;
           xr(1) = ( upper + lower)/2;
           d(1) = subs(f, xr(1));
           errors(1) = nan;
           test = subs(f,xl(1)) * subs(f, xr(1));
           if(test < 0)
               xu(2) = xr(1);
               xl(2) = xl(1);
           else
               xl(2) = xr(1);
               xu(2) = xu (1);
           end
           if(test == 0)
              return;
           end
           i = 2;
           while (i <= imax )
               iteration_number(i) = i;
               xr(i) = ( xl(i) + xu(i))/2;
               d(i) = subs(f, xr(i));
               ea = abs(xr(i)-xr(i-1));
               errors(i) = ea;
               test = subs(f,xl(i)) * subs(f, xu(i));
               if(test < 0)
                   if( i ~= imax)
                        xu(i + 1) = xr(i);
                        xl(i + 1) = xl(i);
                   end
               else
                   if ( i ~= imax)
                       xl(i + 1) = xr(i);
                       xu(i + 1) = xu(i);
                   end
               end
               if(test == 0)
                   ea = 0;
               end
               if(ea < es) 
                   break;
               end
               i = i + 1;
           end
           obj.num_of_iter = i - 1;
        end
        function [xl, xu, maxi, es] = getRequirements(obj)
            prompt = {'Lower bound', 'Upper bound','Maximum number of iterations', 'Relative error tolerance'};
            title = 'Method requirements';
            dims = [1 35];
            definput = {'-5', '5', '50', '0.0001'};
            answer = inputdlg(prompt,title,dims,definput);
            if(~isempty(answer))
                [msg, xl, xu, maxi, es] = obj.validate_input(answer);
                if (msg ~= "")
                     errordlg(msg);
                end
             else
                xl = 0;
                xu = 0;
                es = 0;
                maxi = -1;
            end
        end
        function [msg, xl, xu, maxi, es] = validate_input(obj, user_input)
            msg = '';
            xl = str2double(user_input(1));
            if (isnan(xl))
                msg = strcat(msg, 'Lower bound guess must be a number.');
            end
            xu = str2double(user_input(2));
            if (isnan(xu))
                msg = strcat(msg, ' Upper bound guess must be a number.');
            end
            if (xl > xu)
                msg = strcat(msg, ' Lower bound is greater than upper bound!!');
            end
            maxi = str2double(user_input(3));
            if (isnan(maxi) || maxi <= 0)
                msg =  strcat(msg, ' Maimum number of iterations must be a positive number.');
            end
            es = abs(str2double(user_input(4)));
            if (isnan(es))
                msg = strcat(msg, ' Relative error tolerance must be a number.');
            end
        end
        function root_exist = check_convergence(obj, f, xl, xu)
            if((subs(f,xl) * subs(f,xu)) > 0) 
                root_exist = 0;
            else
                root_exist = 1;
            end
        end
        function [ax, result_view, result_t, next_btn] = create_result_view(obj, f, variable, itr, xl, xu, xr, errs, d)
            result_view = uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
            ax = uiaxes('Parent', result_view, 'Position', [50 50 600 700]);
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';  
            ax.Title.String = 'Result plot';
            fplot(ax, variable, f, [xl(1) xu(1)], 'r-', 'LineWidth', 2);
            zoom(ax, 'on');
            result_t = uitable('Parent', result_view,'Position', [800 100 800 700] ,'ColumnName',{'Iteration number'; 'Xl(i)'; 'Xu(i)'; 'Xr(i)'; '|Error%|'; 'f(Xr(i))'});
            result_t.Visible = 'off';
            next_btn = uibutton(result_view, 'push', 'Position', [50 900 120 50], 'Text', 'NEXT ITERATION', 'ButtonPushedFcn', @(next_btn,event) obj.NextButtonPushed(result_t, itr, xl, xu, xr, errs, d, ax));
            next_btn.Visible = 'off';
        end
        function display_all_result(obj, itr, xl, xu, xr, errs, d, ax, table)
            res_data = [itr(:), xl(:), xu(:), xr(:), errs(:), d(:)];
            res_data = double(res_data);
            set(table, 'Data', res_data);
            table.Visible = 'on';
            ax.NextPlot = 'add';
            l1 = plot(ax, [xl(1) xl(1)], get(ax, 'YLim'), 'k--');
            l2 = plot(ax, [xu(1) xu(1)], get(ax, 'YLim'), 'k--');
            pause(0.5)
            i = 2;
            while (i <= obj.num_of_iter)
                 delete(l1);
                 delete(l2);
                 ax.NextPlot = 'add';
                 l1 = plot(ax, [xl(i) xl(i)], get(ax, 'YLim'), 'k--');
                 l2 = plot(ax, [xu(i) xu(i)], get(ax, 'YLim'), 'k--');
                 pause(0.5);
                i = i + 1;
            end
        end
        function NextButtonPushed(obj, table, itr, xl, xu, xr, errs, d, ax)
            if ~(obj.current_row > obj.num_of_iter)
                ax.NextPlot = 'add';
                delete(obj.ml1);
                delete(obj.ml2);
                obj.ml1 = plot(ax, [xl(obj.current_row) xl(obj.current_row)], get(ax, 'YLim'), 'k--');
                obj.ml2 = plot(ax, [xu(obj.current_row) xu(obj.current_row)], get(ax, 'YLim'), 'k--');
                row = [itr(obj.current_row), xl(obj.current_row), xu(obj.current_row), xr(obj.current_row), errs(obj.current_row), d(obj.current_row)];   
                row = double(row);
                if (obj.current_row == 1)
                    set(table, 'Data', row);
                elseif (obj.current_row <=  obj.num_of_iter)
                    oldData = get(table,'Data');
                    oldData(end + 1, :) = row;
                    set(table, 'Data', oldData);
                end
                table.Visible = 'on';
                obj.current_row = obj.current_row + 1;  
            end
        end
        function err = display_msg(obj, msg_bool, xl, xu, view, root)
            if (msg_bool == 1)
                msg = sprintf('There is a root equals %d', root);
                err = 0;
            else
                msg = 'No root exists in this interval, ';
                err = 1;
            end
            str = sprintf(' for initial values: [ %d , %d ]', xl, xu);
            msg = strcat(msg, str);
            str2 = sprintf('Reguired number of iterations = %d', obj.req_iteration_number);
            msg = [msg newline str2];
            lab = uilabel('Parent', view, 'Position', [50 750 1000 100]);
            lab.Text = msg;
            lab.FontSize = 14;
        end
        function display_execution_time(obj, time, view)
            lab = uilabel('Parent', view, 'Position', [1000 50 1000 100]);
            str = sprintf('Total execution time: %f seconds', time);
            lab.Text = str;
            lab.FontSize = 14;
        end
        function read_file(obj, func_str, user_input, mode)
            f = evalin(symengine, func_str);
            symbols = symvar(f);
            [msg, xl, xu, maxi, es] = obj.validate_input(user_input);
             if (msg ~= "")
                 errordlg(msg);
             else
                 obj.base_algorithm(f, symbols(1), xl, xu, maxi, es, mode);
             end
        end
    end
end