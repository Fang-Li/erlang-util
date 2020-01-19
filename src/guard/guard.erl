-module(guard).
-compile(export_all).

%% 原始的 and/or 是不带短路的，会计算每个 Expression
% and/or 是不捕获异常的，遇到异常的情况下会直接退出，整个 Guard 为 false
% guard_or1(0).
% 0
% guard_or2(0).
% 0
guard_or1(X) when (1/X > 2) or X == 0 ->
    X + 1;
guard_or1(X) ->
    X.

guard_or2(X) when X == 0 or (1/X > 2) ->
    X + 1;
guard_or2(X) ->
    X.


% Expression1 andalso / orelse Expression2 是带有短路的，如果计算 Expression1 即可得到返回值，则不会计算 Expression2

% andalso/orelse 同样不会捕获异常，如果 Expression1 计算异常，则不会计算 Expression2 直接退出，整个 Guard 为 false

% andalso/orelse 可以在 Guard 中嵌套

% 执行结果：

% guard_orelse1(0).
%% 1
% guard_orelse2(0).
%% 0
guard_orelse1(X) when X == 0 orelse (1/X > 2)  ->
    X + 1;
guard_orelse1(X) ->
    X.

guard_orelse2(X) when (1/X > 2) orelse X == 0  ->
    X + 1;
guard_orelse2(X) ->
    X.




% 3. Expression1 ; / , Expression2

% 考虑如下代码：

guard_seq1(X) when  X == 0 ; (1/X > 2) ->
    X + 1;
guard_seq1(X) ->
    X.

guard_seq2(X) when  (1/X > 2); X == 0 ->
    X + 1;
guard_seq2(X) ->
    X.
% Guard Sequence G1; G2; G3; …… 中，只要有一个 Guard 为 true, 整个Guard Sequence 就为 true

% 其实上面这句话可以说得更清晰，即 逐个扫描 Guard 子句,直到有运算结果为 true 的时候停下来。上面的特例 1/0 的执行结果是一个异常，并不是 true，这里异常只是作为一个特殊的返回值来看待的，所以会继续扫描后续 Guard 子句

% ; / , 在 Guard Sequence 是无法嵌套的

% 执行结果：

% guard_seq1(0).
% 1
% guard_seq2(0).
% 1
