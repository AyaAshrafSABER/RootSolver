function [root,num_of_iterations,columnNames,matrix_reslut,absolute_error,plot,error_message] = Newton_Raphson(equation,max_iterations, epsilon,intial_point)
%to display long number%
format long;
eq_derivative = @(x) diff(equation);
%set the values%cd 
matrix = zeros(max_iterations+1,6);
num_of_iterations = 1;
absolute_error = 1000;
error_message = "";
root = 0;
columnNames = {};
plot = diff(equation);
ezplot(plot);
xi = intial_point; 
%put the result of every iteration in the matrix%
matrix_reslut = zeros(max_iterations,6);
while ((num_of_iterations < max_iterations) && (abs(absolute_error) > epsilon))
     functionValue = eval(subs(equation,xi));
     x=xi;
     derivativeValue = eval(eq_derivative(1));
     if (derivativeValue == 0)
           error_message = 'ERROR!!! CAN NOT Divide by ZERO';
          break;
     end
      xnew = xi - ((functionValue) / (derivativeValue));
      absolute_error = xnew - xi;
      matrix(num_of_iterations,1) =  num_of_iterations;
      matrix(num_of_iterations,2) =  xi;
      matrix(num_of_iterations,3) = functionValue; 
      matrix(num_of_iterations,4) = derivativeValue;
      matrix(num_of_iterations,5) =  xnew;
      matrix(num_of_iterations,6) =  abs(absolute_error);
      num_of_iterations = num_of_iterations + 1;
      xi = xnew; 
end 
if (num_of_iterations == max_iterations  && abs(absolute_error) > epsilon)
        error_message = 'Couldnot find the exact root... method may diverged';
end
  num_of_iterations = num_of_iterations - 1;
if(num_of_iterations > 0) 
    absolute_error = matrix(num_of_iterations,6);
    root = matrix(num_of_iterations,5);
    columnNames = {'#Iteration','Xi ','f(xi) ','f"(xi) ','Xi+1 ','|Error|'};
    matrix_reslut = zeros(num_of_iterations,5);
end 
 for i = 1 : num_of_iterations
      for j = 1 : 6
      matrix_reslut(i,j) = matrix (i,j);
      end
 end
 end