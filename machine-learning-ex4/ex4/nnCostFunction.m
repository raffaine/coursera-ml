function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% simple vector used to generate output vec y
Kvec = 1:num_labels;

% functor that calculates A for a layer given Theta T and input I
af = @(T,I)(T * [ones(1,size(I,2)); I]);

% using functor zf, calculates the hypothesis h
A1 = X';

Z2 = af(Theta1, A1);
A2 = sigmoid(Z2);

Z3 = af(Theta2, A2);
A3 = sigmoid(Z3);
h = A3;

Yk = bsxfun(@eq, Kvec, y); %Kvec == y;

% Is it possible to vectorize the cost calculation?
% This is wrong as it computes cross example hypothesis.
%J = -(sum(log(h)*Yk) - sum(log(1-h)*(1-Yk)))/m

% loop to calculate cost
for i=1:m

hk = h(:,i);
yk = Yk(i,:);

J += (-yk*log(hk) - (1-yk)*log(1-hk)); 

end

% Calculate the regularization factor
reg = 0;
for j = 1:size(Theta1,1)

reg += sum(Theta1(j,2:end) .^ 2);
reg += sum(Theta2(:,j+1) .^ 2);

end

%Add it to the Cost
J = J/m + (lambda/(2*m))*reg;


% Back propagation in a vectorized fashion! o.O
del3 = A3 - Yk';
del2 = (Theta2' * del3) .* [ones(1,m); sigmoidGradient(Z2)];

Theta1_grad = (del2(2:end,:) * [ones(1,m); A1]')/m;
Theta2_grad = (del3 * [ones(1,m); A2]')/m;

%Regularize the back propagation
Theta1_grad(:,2:end) += (lambda/m)*(Theta1(:,2:end));
Theta2_grad(:,2:end) += (lambda/m)*(Theta2(:,2:end));

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
