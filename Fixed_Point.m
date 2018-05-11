classdef Fixed_Point < handle
    properties (SetAccess = 'public', GetAccess = 'public')
        current_row = 0;
        num_of_iter = 0;
    end
    methods 
        function base_algorithm(obj, g, var, x0, maxi, es, mode)
           now = tic();
            [itr, root, errs, cnv, way] = obj.execute(g, x0, maxi, es, var);
            [ax, view, table, next_btn] = obj.create_result_view(g, var, itr, root, errs, x0);
            err = obj.display_msg(cnv, way, x0, view);
%             if (err == 0)
                if (mode == "fast")
                    obj.display_all_result(itr, root, errs, ax, x0, table);
                elseif (mode == 'single')
                    next_btn.Visible = 'on';
                    obj.current_row = 0;
                else
                    fast_btn = uibutton(view,'push', 'Position', [800 900 100 50], 'Text', 'FAST MODE', 'ButtonPushedFcn', @(fast_btn,event) obj.FastButtonPushed(table, itr,root, errs, ax, next_btn, x0));
                    slow_btn = uibutton(view ,'push', 'Position', [1000 900 140 50], 'Text', 'SINGLE STEP MODE', 'ButtonPushedFcn', @(slow_btn, event) obj.SlowButtonPushed(next_btn)); 
                end
%             end
            wholeTime = toc(now);
            obj.display_execution_time(wholeTime, view); 
        end
        function FastButtonPushed(obj, table, itr,root, errs, ax, btn, x0)
            btn.Visible = 'off';
            obj.display_all_result(itr, root, errs, ax, x0, table);
        end
        function SlowButtonPushed(obj, next_btn)
            next_btn.Visible = 'on';
            obj.current_row = 0;
        end
        function solve(obj, eq_as_str, mode)
            f = evalin(symengine, eq_as_str);
            symbols = symvar(f);
            g = f + symbols(1);
            [x0, maxi, es] = obj.getRequirements();
            if(maxi ~= -1)
                obj.base_algorithm(g, symbols(1), x0, maxi, es, mode);
            end 
        end
        function [iteration_number, root, errors, cnv, way] = execute(obj,g, initial_guess, max_iterations, es, variable)
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
           obj.num_of_iter = i - 1;
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
        function [ax, result_view, result_t, next_btn] = create_result_view(obj, g, variable, itr, roots, errs, x0)
            result_view = uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
            ax = uiaxes('Parent', result_view, 'Position', [50 50 600 700]);
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';   
            ax.Title.String = 'Result plot';
            fplot(ax, variable, g, [-10 10], 'r-', 'LineWidth', 2);
            y = variable;
            zoom(ax, 'on');
            ax.NextPlot = 'add';
            fplot(ax, variable, y, [-10 10], 'b-', 'LineWidth', 2);
            result_t = uitable('Parent', result_view,'Position',   [800 200 800 500]  ,'ColumnName',{'Iteration number'; 'X(i)'; '|Error%|'});
            result_t.Visible = 'off';
            next_btn = uibutton(result_view, 'push', 'Position', [50 900 120 50], 'Text', 'NEXT ITERATION', 'ButtonPushedFcn', @(next_btn,event) obj.NextButtonPushed(result_t, itr, roots, errs, ax, x0));
            next_btn.Visible = 'off';
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
            elseif (obj.current_row < obj.num_of_iter)
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
            elseif (obj.current_row == obj.num_of_iter)
                newRow = [itr(obj.current_row); root(obj.current_row); errs(obj.current_row)];
                newRow = double(newRow);
                oldData = get(table,'Data');
                oldData(end + 1, :) = newRow;
                set(table,'Data',oldData);
                table.Visible = 'on';
                obj.current_row = obj.current_row + 1;
            end
        end
        function display_all_result(obj, itr, root, errs, ax, x0, table)
            first_row = [0, x0, 0];
            first_row = double(first_row);
            res_data = [itr(:), root(:), errs(:)];
            res_data = double(res_data);
            all_data = [first_row; res_data];
            all_data = double(all_data);
            set(table, 'Data', all_data);
            table.Visible = 'on';
            ax.NextPlot = 'add';
            plot(ax, [x0 x0], [x0 root(1)], 'k--');
            ax.NextPlot = 'add';
            plot(ax, [x0 root(1)], [root(1) root(1)], 'k--');
            pause(0.5);
            i = 1;
            while (i < obj.num_of_iter)
                ax.NextPlot = 'add';
                plot(ax, [root(i) root(i)], [root(i) root(i + 1)], 'k--');
                ax.NextPlot = 'add';
                plot(ax, [root(i) root(i + 1)], [root(i + 1) root(i + 1)], 'k--');
                i = i + 1;
                pause(0.5);
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
        function read_file(obj, func_str, user_input, mode)
            f = evalin(symengine, func_str);
            symbols = symvar(f);
            g = f + symbols(1);
            [msg, x0, maxi, es] = obj.validate_input(user_input);
             if (msg ~= "")
                 errordlg(msg);
             else
                 obj.base_algorithm(g, symbols(1), x0, maxi, es, mode);
             end
        end
    end
end

