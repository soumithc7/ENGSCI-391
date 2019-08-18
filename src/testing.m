% Test cases for fullrsm and related functions.

clear
clc

% Toggles for tests:
tests = 1:18;

% Numerical errors can mean equality is not achieved within a machine
% epsilon. We will define our own "equality" and maximum error.
max_err = 1e-4;
equal = @(a,b) abs(a-b) < max_err;


%% Test 1: Unit costs and nearly identity constraints
if ismember(1,tests)
    m = 1;
    n = m+1;
    c = ones(n,1);
    A = [eye(m),eye(m,1)];
    b = ones(m,1);
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert(z == m)
    assert( all(x == [ones(m,1);0]) || all(x == [0;ones(m,1)]) )
    assert(pi == ones(m,1))
end

%% Test 2: Unit costs and nearly identity constraints - Bigger
if ismember(2,tests)
    m = 100;
    n = m+1;
    c = ones(n,1);
    A = [eye(m),eye(m,1)];
    b = ones(m,1);
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert(z == m)
    assert( all(x == [ones(m,1);0]) || all(x == [0;ones(m,1)]) )
    assert(all(pi == ones(m,1)))
end

%% Test 3: Chair manufacturing example
if ismember(3,tests)
    m = 2;
    n = 4;
    c = [-100; -150; 0; 0];
    A = [1, 2, 1, 0; ...
        3, 1.5, 0, 1];
    b = [40; 48];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( z == dot( A(:,[1,2])\b , c([1,2]) ) )
    assert( all(x == [8;16;0;0]) )
    assert( all( equal(pi,[-200/3; -100/9]) ))
end

%% Test 4: Chair manufacturing example - chair C
if ismember(4,tests)
    m = 2;
    n = 5;
    c = [-100; -150; -120; 0; 0];
    A = [1, 2, 1, 1, 0; ...
        3, 1.5, 2, 0, 1];
    b = [40; 48];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( equal(z,-3648) )
    assert( all( equal(x,[0;12.8;14.4;0;0]) ))
    assert( all( equal(pi,[-48; -36]) ))
end

%% Test 5: Farmer with wheat and Rye example
if ismember(5,tests)
    m = 3;
    n = 5;
    c = [-500; -300; 0; 0; 0];
    A = [1, 1, -1, 0, 0; ...
        200, 100, 0, 1, 0; ...
        10, 20, 0, 0, 1];
    b = [7; 1200; 120];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( z == -3200 )
    assert( all( equal(x,[4;4;1;0;0]) ))
    assert( all( equal(pi,[0; -2-1/3;-3-1/3]) ))
end

%% Test 6: Chair manufacturing example - cost change
if ismember(6,tests)
    m = 2;
    n = 4;
    c = [-75; -150; 0; 0];
    A = [1, 2, 1, 0; ...
        3, 1.5, 0, 1];
    b = [40; 48];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( z == -3000 )
    assert( all(x == [8;16;0;0]) )
    assert( all( equal(pi,[-75; 0]) ))
end

%% Test 7: Chair manufacturing example - min no of A
if ismember(7,tests)
    m = 3;
    n = 5;
    c = [-100; -150; 0; 0; 0];
    A = [1, 2, 1, 0, 0; ...
        3, 1.5, 0, 1, 0; ...
        1, 0, 0, 0, -1];
    b = [40; 48; 7];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( z == -3200 )
    assert( all(x == [8;16;0;0;1]) )
    assert( all( equal(pi,[-200/3; -100/9; 0]) ))
end

%% Test 8: Right hand side dependency
if ismember(8,tests)
    for k = rand(1,9)
        m = 3;
        n = 6;
        c = [3; 4; 5; 0; 0; 0];
        A = [-1, 1, -1, 1, 0, 0; ...
            2, -1, 1, 0, 1, 0; ...
            1, 0, 1, 0, 0 , -1];
        b = [0; 0; k];
        [result,z,x,pi] = fullrsm(m,n,c,A,b);
        assert(result == 1)
        assert(equal(z,9*k))
        assert( all(x == [0;k;k;0;0;0]) )
        assert( all( equal(pi,[0; -4; 9]) ))
    end
end

%% Test 9: Trivial infeasibility
if ismember(9,tests)
    m = 3;
    n = 5;
    c = (1:n).';
    A = [1,1,1,0,0; ...
        1,0,0,1,0; ...
        0,1,0,0,-1];
    b = [3;2;4];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 0)
end

%% Test 10: Trivial unboundedness
if ismember(10,tests)
    m = 1;
    n = 2;
    c = [-3;0];
    A = [1,-1];
    b = 2;
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == -1)
end

%% Test 11: Diet LPs Tarawera
if ismember(11,tests)
    Energy = [1960	1660	1690	1010	2530	1640	370	636	1100	428	1460	255	160	1570	435	332	720	411	596	2474
    ];
    Protein = [8.2	12.7	9.7	11.2	30	9.3	5.4	22.2	0.4	23	12.1	3.1	3.7	19	18.1	2.8	2.1	10.3	12.8	8.2
    ];
    Fat = [20.6	4.3	11.9	2.8	50	9.6	1	6.5	0.2	1.1	1.5	3.3	0.4	33.4	2.4	1.4	8.5	0	10.1	42.7
    ];
    Carbs = [62.5	72.6	57.7	39	7.2	62.7	14	1.1	63.2	0	65.9	4.7	4.4	1	2.1	11.4	19.9	8.1	0.3	44.4
    ];
    Sugar = [7.6	3.3	28.4	3.8	4.7	16.5	6.2	0.1	63	0	2.6	4.7	4.9	1	0.6	6.1	0.4	1.3	0.3	30.9
    ];
    Salt = [970	190	42	400	310	20	450	74	5	190	275	40	45	470	1198	5	450	6458	133	60
    ];
    Maxes = [8450; 48.5; 66.1;320.6;180.3;2100];

    % Maximimise salt intake
    m = 5;
    n = 25;
    c = [-Salt,zeros(1,5)].';
    A = [[Energy;Protein;Fat;Carbs;Sugar],eye(5)];
    b = Maxes(1:5);
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert( result == 1)
    assert(round(z) == -30409)
    assert( equal(x(18),4.70873786407766) )
    assert( equal(pi(2),-626.990291262135) )
    
    % Maximise energy intake
    c = [-Energy,zeros(1,5)].';
    A = [[Protein;Fat;Carbs;Sugar;Salt],eye(5)];
    b = Maxes(2:6);
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( round(z) == -9385 )
end

%% Test 12: Many-fold Degeneracy
if ismember(12,tests)
    m = 100;
    n = 2*m;
    c = [-eye(m,1);zeros(m,1)];
    A = [repmat(rand(1,m),m,1),eye(m)];
    b = ones(m,1);
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert( equal(z,-1/A(1,1)) )
    assert( equal(x(1),1/A(1,1)) )
    assert( all(equal(x(2:n),zeros(n-1,1))) )
end

%% Test 13: Kicking out leaving variables from the varstatus vector.
if ismember(13,tests)
    A = [1,1,0,0,0,0;...
        0,0,1,1,0,0;...
        0,0,0,0,1,1;...
        1,0,1,0,1,0;...
        0,1,0,1,0,1];
    b = [3;2;5;4;6];
    c = [4;5;3;3;6;1];
    m = 5; n = 6;
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert( result == 1 );
    assert( all(equal(x,[3;0;1;1;0;5])) );
    %assert( all(equal(pi,[4;3;1;0;0])) );
    assert( equal(z,23) ); 
end

%% Test 14: General error check - may bake your CPU.
% The idea is that it will try a lot of randomly assorted LPs so hopefully
% if any weird phenomena are possible they will arise. I'd encourage
% setting max_size quite high and leaving the test to run for some time.
% This doesn't check any results: just that your function gets called
% without throwing any errors.
result = [];
if ismember(14,tests)
    max_size = 25;
    max_value = 20;
    for m = 1:(max_size-1)
        for n = (m+1):max_size
            for j = 1:10
                A = randi([-max_value,max_value],m,n);
                b = randi([0,max_value],m,1);
                c = randi([-max_value,max_value],n,1);
                result = [result, fullrsm(m,n,c,A,b)];
            end
        end
    end
    % For your enjoyment (Maybe!) a histogram of what proportion of the
    % randomly generated LPs were infeasible, unbounded, and feasible
    % It doubles as a way to let you know the (potentially long test) has
    % finished running.
    % As max_size approaches infinity, the number of feasible LPs becomes
    % sparce and approaches zero, while the proportion of unbounded to
    % infeasible is roughly an even split.
    histogram(result)
end

%% Test 15: General solution check - will definitely bake the CPU
% Same as before but now checks the solutions are correct too.
% This will test on
% ntests / 2 * ((m - 1)^2 + m - 1)
clc
i = 0;

% If you push max_size too high, you need to push max_error (a.k.a tol) higher!
if ismember(15,tests)
    max_size = 20;
    max_value = 5;
    num_tests_at_dim = 1;
    tot_num_tests = num_tests_at_dim/2*((max_size-1)^2 + max_size-1);
    for m = 1:(max_size-1)
        for n = (m+1):max_size
            for j = 1:num_tests_at_dim
                A = randi([-max_value,max_value],m,n);
                b = randi([0,max_value],m,1);
                c = randi([-max_value,max_value],n,1);
                [result,z,x,~] = fullrsm(m,n,c,A,b);
                if result == 1
                    options = optimoptions('linprog','Algorithm','dual-simplex');
                    [~,xopt,z_true] = evalc('linprog(c,[],[],A,b,zeros(n,1),[],options);');
                    if ~all(equal( z_true, z ))
                        disp(z_true-z)
                        disp(xopt-x)
                    end

                    assert(all(equal( z_true, z )))
                end
                i = i+1;
            end
            clc
            fprintf('Test 15 Progress: %.2f%%\n\n', 100*i/tot_num_tests)
        end
    end
    fprintf('In Test 15, you solved %d LPs!!!\n\n', tot_num_tests );
end

%% Test 16: Particular case Nathan failed while running test 15
if ismember(16,tests)
    m = 2;
    n = 7;
    c = [4;-16;5;5;0;-7;3];
    A = [11,13,7,1,4,8,8; ...
        8,-6,6,-9,4,-14,8];
    b = [2; 2];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    assert(equal(z,0))
    assert( all(equal(x,[0,0,0,0,0.5,0,0].')) )
end

%% Test 17: Another particular case Nathan failed while running test 15
if ismember(17,tests)
    m = 2;
    n = 3;
    c = [14;8;-13];
    A = [1,-1,15; ...
        0,-6,-3];
    b = [8; 0];
    [result,z,x,pi] = fullrsm(m,n,c,A,b);
    assert(result == 1)
    % disp(z)
    % disp(x)
    assert(equal(z,112))
    assert( all(equal(x,[8;0;0])) )
end

%% Test 18: Particular case Niklas and Alex failed while running test 15
% check if you account for machine imprecision
if ismember(18, tests)
   m = 5;
   n = 8;
   c = [-4;3;-2;0;0;5;0;-4];
   b = [3;4;5;0;0];
   A = [3,4,5,1,-2,3,-3,-2;-4,1,-5,-3,5,4,5,4;-3,-2,-5,1,4,1,5,4;4,5,-2,1,-4,5,-1,-5;4,2,-5,4,4,-5,2,-3];
   [result,z,x,pi] = fullrsm(m,n,c,A,b);
   assert(result == 1)
   assert(equal(z, -15.1698))
   assert( all(equal(x, [2.207547169811321;0;0;0.150943396226416;0;0.603773584905660;0.301886792452830;2.339622641509434])))
end

%% Test 19: Another particular case Niklas and Alex failed while running test 15
% check infeasibility in phase 1
if ismember(19, tests)
   m = 4;
   n = 9;
   c = [-3;-2;-2;5;5;-1;-4;3;-3];
   b = [1;2;2;4];
   A = [-3,-4,-4,-4,-3,-4,2,5,-2;-4,3,5,3,2,1,4,-4,3;-1,0,-5,4,1,-3,1,-5,0;5,3,1,2,1,-2,-2,-3,1];
   [result,z,x,pi] = fullrsm(m,n,c,A,b);
   assert(result == 0)
%    dunno about these asserts, kinda depends on how your code works - if
%    these don't match it's probably not a problem
%    assert(equal(z, 3.6667))
%    assert( all(equal(x, [1.128205128205128;0;0;0.461538461538462;0;0;1.282051282051282;0;0])))
end

%% Success message
disp('You have passed all of the following tests:')
disp(tests)