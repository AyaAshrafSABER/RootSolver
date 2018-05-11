classdef False_Position < handle
    properties
        current_row = 0;
        ml1
        ml2
    end
    methods
        function solve(obj, eq_as_str, mode)
            f = evalin(symengine, eq_as_str);
            symbols = symvar(f);
            [xl_init, xu_init, maxi,es] = obj.getRequirements();
            if(maxi ~= -1)
                now = tic();
                [itr, xl, xu, xr, yl, yu, yr, errs, root_exist, tol_msg] = obj.execute(f, xl_init, xu_init, maxi,es);
                [ax, view, table] = obj.create_result_view(f, symbols(1), mode, itr, xl, xu, xr, yl, yu, yr, errs);
                err = obj.display_msg(root_exist, xl_init, xu_init, view, xr(length(itr)), tol_msg);
    %             if (err == 0)
                    if (mode == "fast")
                        obj.display_all_result(itr, xl, xu, xr, yl, yu, yr, errs, ax, table);
                    else
                        obj.current_row = 1;
                    end
    %             end
                wholeTime = toc(now);
                obj.display_execution_time(wholeTime, view);
            end 
        end
        function [ax, result_view, result_t] = create_result_view(obj, f, variable, mode, itr, xl, xu, xr, yl, yu, yr, errs)
            result_view = uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
            ax = uiaxes('Parent', result_view, 'Position', [50 50 600 700]);
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';  
            ax.Title.String = 'Result plot';
            fplot(ax, variable, f, [xl(1) xu(1)], 'r-', 'LineWidth', 2);
            zoom(ax, 'on');
            result_t = uitable('Parent', result_view,'Position', [800 700 800 300] ,'ColumnName',{'Iteration number'; 'Xl(i)'; 'Yl(i)'; 'Xu(i)'; 'Yu(i)'; 'Xr(i)'; 'Yr(i)'; '|Error%|'});
            result_t.Visible = 'off';
            next_btn = uibutton(result_view, 'push', 'Position', [50 900 120 50], 'Text', 'NEXT ITERATION', 'ButtonPushedFcn', @(next_btn,event) obj.NextButtonPushed(result_t, itr, xl, xu, xr, yl, yu, yr, errs, ax));
            if (mode == "fast")
                next_btn.Visible = 'off';
            end
        end
        function [iteration_number, xl, xu, xr, fxl, fxu, fxr, errors, root_exist, tolerance_msg] = execute(obj,f, lower, upper, imax, es)
            xr = zeros(1,imax);
            fxr = zeros(1,imax);
            xl = zeros(1,imax);
            xu = zeros(1,imax);
            fxu = zeros(1,imax);
            fxl = zeros(1,imax);
            xl(1) = lower;
            xu(1) = upper;
            root = nan;
            iteration_number = zeros(1, imax);
            errors = zeros(1, imax);
            errors(1) = nan;
            tolerance_msg = '';
            root_exist = obj.check_convergence(f, lower, upper);
            for i = 1:1:imax
                xr(i) = obj.linear_interpolation(fxl(i), fxu(i), xl(i), xu(i));
                fxr(i) = subs(f,xr(i));
                if fxr(i) == 0 
                    root = xr(i);
                    break;
                elseif fxr(i)*fxl(i) < 0
                    xl(i+1) = xl(i);
                    fxl(i+1) = fxl(i);
                    xu(i+1) = xr(i);
                    fxu(i+1) = fxr(i);
                else 
                    xu(i+1) = xu(i);
                    fxu(i+1) = fxu(i);
                    xl(i+1) = xr(i);
                    fxl(i+1) = fxr(i);
                end
                if (i>1) 
                    ea = (xr(i) - xr(i - 1) / xr(i)) * 100;
                    errors(i) = ea;
                    if (ea < es)
                        tolerance_msg = strcat(tolerance_msg, 'Method converged');
                        break;
                    end
                end
                iteration_number(i) = i;
            end
            if(isnan(root))
                tolerance_msg = strcat(tolerance_msg, 'Zero not found for desired tolerance');
            end
        end
        function result = linear_interpolation(obj, fxl, fxu, xl, xu)
            result = (xl * fxu - xu * fxl)/(fxu - fxl);
        end          
        function root_exist = check_convergence(obj, f, xl, xu)
                if((subs(f,xl) * subs(f,xu)) > 0) 
                    root_exist = 0;
                else
                    root_exist = 1;
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
        function display_all_result(obj, itr, xl, xu, xr, yl, yu, yr, errs, ax, table)
            res_data = [itr(:); xl(:); yl(:); xu(:); yu(:); xr(:); yr(:); errs(:)];
            res_data = double(res_data);
            table.Data = res_data;
            table.Visible = 'on';
            ax.NextPlot = 'add';
            l1 = plot(ax, [xl(1) xl(1)], get(ax, 'YLim'), 'k--');
            l2 = plot(ax, [xu(1) xu(1)], get(ax, 'YLim'), 'k--');
            pause(0.5)
            i = 2;
            while (i <= length(itr))
                 delete(l1);
                 delete(l2);
                 ax.NextPlot = 'add';
                 l1 = plot(ax, [xl(i) xl(i)], get(ax, 'YLim'), 'k--');
                 l2 = plot(ax, [xu(i) xu(i)], get(ax, 'YLim'), 'k--');
                 pause(0.5);
                i = i + 1;
            end
        end
        function NextButtonPushed(obj, table, itr, xl, xu, xr, yl, yu, yr, errs, ax)
            ax.NextPlot = 'add';
            delete(obj.ml1);
            delete(obj.ml2);
            obj.ml1 = plot(ax, [xl(obj.current_row) xl(obj.current_row)], get(ax, 'YLim'), 'k--');
            obj.ml2 = plot(ax, [xu(obj.current_row) xu(obj.current_row)], get(ax, 'YLim'), 'k--');
            row = [itr(obj.current_row), xl(obj.current_row), yl(obj.current_row), xu(obj.current_row), yu(obj.current_row), xr(obj.current_row), yr(obj.current_row), errs(obj.current_row)];   
            row = double(row);
            if (obj.current_row == 1)
                set(table, 'Data', row);
            elseif (obj.current_row <= length(itr))
                oldData = get(table,'Data');
                oldData(end + 1, :) = row;
                set(table, 'Data', oldData);
            end
            table.Visible = 'on';
            obj.current_row = obj.current_row + 1;  
        end
        function err = display_msg(obj, msg_bool, xl, xu, view, root, tol_msg)
            if (msg_bool == 1)
                msg = sprintf('There is a root equals %d', root);
                err = 0;
            else
                msg = 'No root exists in this interval, ';
                err = 1;
            end
            str = sprintf(' for initial values: [ %d , %d ] \n', xl, xu);
            msg = strcat(msg, str);
            if (tol_msg ~= "")
                msg = strcat(msg, tol_msg);
            end
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
                     maxi = -1;
                end
             else
                x0 = 0;
                es = 0;
                maxi = -1;
            end
        end
    end
end