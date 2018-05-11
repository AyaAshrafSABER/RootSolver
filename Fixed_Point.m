classdef Fixed_Point < handle
    properties (SetAccess = 'public', GetAccess = 'public')
        current_row = 0;
    end
    methods 
        function solve(obj, eq_as_str, mode)
            f = evalin(symengine, eq_as_str);
            symbols = symvar(f);
            g = f + symbols(1);
            [x0, maxi, es] = obj.getRequirements();
            if(maxi ~= -1)
                now = tic();
                [itr, root, errs, cnv, way] = obj.execute(g, x0, maxi, es, symbols(1));
                [ax, view] = obj.create_result_view(g, symbols(1), mode, itr, root, errs, x0);
                err = obj.display_msg(cnv, way, x0, view);
    %             if (err == 0)
                    if (mode == "fast")
                        obj.display_all_result(itr, root, errs, view, ax, x0);
                    else
                        obj.current_row = 0;
                    end
    %             end
                wholeTime = toc(now);
                obj.display_execution_time(wholeTime, view);
            end 
        end
        function [iteration_number, root, errors, cnv, way] = execute(obj,g, initial_guess, max_iterations, es, variable)
           iteration_number = zeros(1, max_iterations);
           root = zeros(1, max_iterations);
           errors = zeros(1, max_iterations);
           
           xr_old = initial_guess;
           i = 1;
           ea = es + 1;
           [cnv, way] = obj.check_convergence(g, variable, initial_guess);
%            if (cnv == 0)
%                iteration_number = 0;
%                root = 0;
%                errors = 0;
%                return;
%            end
           while (i <= max_iterations) && (ea > es)
                xr = subs(g, xr_old);
                if (xr ~= 0)
                    ea =  abs((xr - xr_old) / xr) * 100;
                end
                iteration_number(i) = i;
                root(i) = xr;
                errors(i) = ea;
                [cnv, way] = obj.check_convergence(g, variable, xr);
                xr_old = xr;
                i = i + 1;
           end
        end
        function [cnv, way] = check_convergence(obj, g, variable, value)
            df = diff(g, variable);
            val = (subs(df, value));
            if (val >= 0)
                way = 'monotonic';
            else
                way = 'oscillate';
            end
            val = abs(val);
            if (val >= 1)
                cnv = 0;
            else
                cnv = 1;
            end
        end
        function [x0, maxi, es] = getRequirements(obj)
            prompt = {'Initial guess:', 'Maximum number of iterations', 'Relative error tolerance'};
            title = 'Method requirements';
            dims = [1 35];
            definput = {'0.0', '50', '0.0001'};
            answer = inputdlg(prompt,title,dims,definput);
            if(~isempty(answer))
                [msg, x0, maxi, es] = obj.validate_input(answer);
                if (msg ~= "")
                     errordlg(msg);
                end
            else
                x0 = 0;
                es = 0;
                maxi = -1;
            end
        end
        function [msg,x0, maxi, es] = validate_input(obj, user_input)
            msg = '';
            x0 = str2double(user_input(1));
            if (isnan(x0))
                msg = strcat(msg, 'Initial guess must be a number. ');
            end
            maxi = str2double(user_input(2));
            if (isnan(maxi) || maxi <= 0)
                msg =  strcat(msg, ' Maimum number of iterations must be a positive number. ');
            end
            es = abs(str2double(user_input(3)));
            if (isnan(es))
                msg = strcat(msg, ' Relative error tolerance must be a number.');
            end
        end
        function [ax, result_view] = create_result_view(obj, g, variable, mode, itr, roots, errs, x0)
            result_view = uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
            ax = uiaxes('Parent', result_view, 'Position', [50 50 600 700]);
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';   
            ax.Title.String = 'Result plot';
            fplot(ax, variable, g, [-50 50], 'r-', 'LineWidth', 2);
            y = variable;
            zoom(ax, 'on');
            ax.NextPlot = 'add';
            fplot(ax, variable, y, [-50 50], 'b-', 'LineWidth', 2);
            result_t = uitable('Parent', result_view,'Position', [800 700 800 300] ,'ColumnName',{'Iteration number'; 'X(i)'; '|Error%|'});
            result_t.Visible = 'off';
            next_btn = uibutton(result_view, 'push', 'Position', [50 900 120 50], 'Text', 'NEXT ITERATION', 'ButtonPushedFcn', @(next_btn,event) obj.NextButtonPushed(result_t, itr, roots, errs, ax, x0));
            if (mode == "fast")
                next_btn.Visible = 'off';
            end
        end
        function NextButtonPushed(obj, table, itr, root, errs, ax, x0)
            if (obj.current_row == 0)
                ax.NextPlot = 'add';
                plot(ax, [x0 x0], [x0 root(obj.current_row + 1)], 'k--');
                ax.NextPlot = 'add';
                plot(ax, [x0 root(obj.current_row + 1)], [root(obj.current_row + 1) root(obj.current_row + 1)], 'k--');
                first_row = [0, x0, nan];
                set(table, 'Data', first_row);
                table.Visible = 'on';
                obj.current_row = obj.current_row + 1;  
            elseif (obj.current_row < length(itr))
                newRow = [itr(obj.current_row); root(obj.current_row); errs(obj.current_row)];
                newRow = double(newRow);
                oldData = get(table,'Data');
                oldData(end + 1, :) = newRow;
                set(table,'Data',oldData);
                table.Visible = 'on';
                ax.NextPlot = 'add';
                plot(ax, [root(obj.current_row) root(obj.current_row)], [root(obj.current_row) root(obj.current_row + 1)], 'k--');
                ax.NextPlot = 'add';
                plot(ax, [root(obj.current_row) root(obj.current_row + 1)], [root(obj.current_row + 1) root(obj.current_row + 1)], 'k--');
                obj.current_row = obj.current_row + 1;
            elseif (obj.current_row == length(itr))
                newRow = [itr(obj.current_row); root(obj.current_row); errs(obj.current_row)];
                newRow = double(newRow);
                oldData = get(table,'Data');
                oldData(end + 1, :) = newRow;
                set(table,'Data',oldData);
                table.Visible = 'on';
                obj.current_row = obj.current_row + 1;
            end
        end
        function display_all_result(obj, itr, root, errs, view, ax, x0)
            result_t = uitable('Parent', view,'Position', [800 700 800 300] ,'ColumnName',{'Iteration number'; 'X(i)'; '|Error%|'});
            first_row = [0, x0, nan];
            first_row = double(first_row);
            res_data = [itr(:), root(:), errs(:)];
            res_data = double(res_data);
            all_data = [first_row; res_data];
            result_t.Data = all_data;
            ax.NextPlot = 'add';
            plot(ax, [x0 x0], [x0 root(1)], 'k--');
            ax.NextPlot = 'add';
            plot(ax, [x0 root(1)], [root(1) root(1)], 'k--');
            i = 1;
            while (i < length(itr))
                ax.NextPlot = 'add';
                plot(ax, [root(i) root(i)], [root(i) root(i + 1)], 'k--');
                ax.NextPlot = 'add';
                plot(ax, [root(i) root(i + 1)], [root(i + 1) root(i + 1)], 'k--');
                i = i + 1;
            end
        end
        function err = display_msg(obj, cnv, way, x0, view)
            if (cnv == 1)
                msg = 'Function converges in this interval, ';
                err = 0;
            else
                msg = 'Function will diverge in this interval, ';
                err = 1;
            end
            msg = strcat(msg, way);
            str = sprintf(' for initial value: %d', x0);
            msg = strcat(msg, str);
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
    end
end

