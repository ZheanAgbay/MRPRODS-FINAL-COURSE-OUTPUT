% Decision Variables %
x1 = optimvar('cpu', 2, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
x2 = optimvar('gpu', 2, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
x3 = optimvar('ram', 2, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
x4 = optimvar('ssd', 2, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
x5 = optimvar('psu', 2, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

% Component Prices (PHP) %
price_x1 = [17499; 13995];
price_x2 = [8495; 5399];
price_x3 = [5250; 3295];
price_x4 = [3550; 1195];
price_x5 = [2995; 3395];

% Benchmark Scores %
score_x1 = [13161; 22983];
score_x2 = [7871; 7744];
score_x3 = [13; 19.9];
score_x4 = [1559; 1984];
score_x5 = [76.09; 72.64];

% Component Specifications %
cpu_cores = [8; 8];        
cpu_clock = [3.0; 3.9];     
gpu_vram  = [4; 4];          
ram_cap   = [8; 8];           
ssd_cap   = [256; 256];       
psu_watts = [650; 650];     

% Power Drawn Parameters (Based on CPU/GPU models TDP) %
draw_cpu = [65; 105];
draw_gpu = [75; 53];  

% Minimum Thresholds / Constants %
max_budget = 60000;
min_cores  = 8;
min_clock  = 3.0;
min_vram   = 4;
min_ram    = 8;
min_ssd    = 256;

% Objective Function (Maximize Z) %
prob = optimproblem('Objective', sum(score_x1 .* x1) + sum(score_x2 .* x2) + sum(score_x3 .* x3) + sum(score_x4 .* x4) + sum(score_x5 .* x5), 'ObjectiveSense', 'max');

% Constraints %
% Budget Constraint %
prob.Constraints.budget = sum(price_x1 .* x1) + sum(price_x2 .* x2) + sum(price_x3 .* x3) + sum(price_x4 .* x4) + sum(price_x5 .* x5) <= max_budget;

% Performance Constraints %
prob.Constraints.minCores = sum(cpu_cores .* x1) >= min_cores;
prob.Constraints.minClock = sum(cpu_clock .* x1) >= min_clock;
prob.Constraints.minVram  = sum(gpu_vram .* x2) >= min_vram;
prob.Constraints.minRam   = sum(ram_cap .* x3) >= min_ram;
prob.Constraints.minSsd   = sum(ssd_cap .* x4) >= min_ssd;

% Power Supply Constraint %
prob.Constraints.psuPower = sum(psu_watts .* x5) >= 1.25 * (sum(draw_cpu .* x1) + sum(draw_gpu .* x2));

% Cardinality Constraints %
prob.Constraints.card_cpu = sum(x1) == 1;
prob.Constraints.card_gpu = sum(x2) == 1;
prob.Constraints.card_ram = sum(x3) == 1;
prob.Constraints.card_ssd = sum(x4) == 1;
prob.Constraints.card_psu = sum(x5) == 1;

% Solve %
[sol, fval, exitflag, output] = solve(prob);

% Total Pricing of Optimized Build %
total_price = sum(price_x1 .* round(sol.cpu)) + sum(price_x2 .* round(sol.gpu)) + sum(price_x3 .* round(sol.ram)) + sum(price_x4 .* round(sol.ssd)) + sum(price_x5 .* round(sol.psu));

disp('--- MILP Results ---');
fprintf('Maximized PC Build Performance Score: %.2f\n', fval);
fprintf('Total Amount of Maximized PC Build: PHP %.2f\n', total_price);
disp('Selected Components (1 = Selected, 0 = Not Selected):');
disp('CPU:'); disp(sol.cpu);
disp('GPU:'); disp(sol.gpu);
disp('RAM:'); disp(sol.ram);
disp('SSD:'); disp(sol.ssd);
disp('PSU:'); disp(sol.psu);