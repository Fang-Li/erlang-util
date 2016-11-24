%% coding: latin-1
%% src/guard.erl:4: Warning: Non-UTF-8 character(s) detected, but no encoding declared. Encode the file in UTF-8 or add "%% coding: latin-1" at the beginning of the file. Retrying with latin-1 encoding.

-module(guard).
-compile(export_all).

%% ԭʼ�� and/or �ǲ�����·�ģ������ÿ�� Expression
% and/or �ǲ������쳣�ģ������쳣������»�ֱ���˳������� Guard Ϊ false
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
    
    
% Expression1 andalso / orelse Expression2 �Ǵ��ж�·�ģ�������� Expression1 ���ɵõ�����ֵ���򲻻���� Expression2

% andalso/orelse ͬ�����Ჶ���쳣����� Expression1 �����쳣���򲻻���� Expression2 ֱ���˳������� Guard Ϊ false

% andalso/orelse ������ Guard ��Ƕ��

% ִ�н����

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

% �������´��룺

guard_seq1(X) when  X == 0 ; (1/X > 2) ->
    X + 1;
guard_seq1(X) ->
    X.

guard_seq2(X) when  (1/X > 2); X == 0 ->
    X + 1;
guard_seq2(X) ->
    X.
% Guard Sequence G1; G2; G3; ���� �У�ֻҪ��һ�� Guard Ϊ true, ����Guard Sequence ��Ϊ true

% ��ʵ������仰����˵�ø��������� ���ɨ�� Guard �Ӿ�,ֱ����������Ϊ true ��ʱ��ͣ��������������� 1/0 ��ִ�н����һ���쳣�������� true�������쳣ֻ����Ϊһ������ķ���ֵ�������ģ����Ի����ɨ����� Guard �Ӿ�

% ; / , �� Guard Sequence ���޷�Ƕ�׵�

% ִ�н����

% guard_seq1(0).
% 1
% guard_seq2(0).
% 1
    