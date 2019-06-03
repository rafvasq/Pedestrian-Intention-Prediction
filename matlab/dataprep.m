files = dir('..\..\PedestrianData\CleanData\*.txt');
newDir = '..\..\PedestrianData\IntentionData\';

step = 1;
nbins = 8;

for file = files'
    trial = load("..\..\PedestrianData\CleanData\" + file.name);
    [rows, columns] = size(trial);
    for row = step:step:rows       
        % Set the first row data
        if row == step

            % Calcluating head pose data
            cur_gaz = [ trial(row, 5), trial(row, 6), trial(row, 7)]; 
            gaz_d = atan(cur_gaz(3) / cur_gaz(1)) * (360/pi);
            dir_gaz = ceil( mod((gaz_d + 22.5)/45, nbins) );
            
            trial(row, 8) = 0;          % vel x
            trial(row, 9) = 0;          % vel z
            trial(row, 10) = 0;         % acc x
            trial(row, 11) = 0;         % acc z
            trial(row, 12) = 0;         % vel magnitude
            trial(row, 13) = 0;         % acc magnitude
            trial(row, 14) = 0;         % vel angle
            trial(row, 15) = 0;         % acc angle
            trial(row, 16) = gaz_d;     % gaze angle
            trial(row, 17) = 0;         % vel 8-bin
            trial(row, 18) = 0;         % acc 8-bin
            trial(row, 19) = dir_gaz;   % gaze 8-bin

        else
            % Set variables
            last_vel =  [ trial(row-step, 8), trial(row-step, 9) ];
            last_pos =  [ trial(row-step, 2), trial(row-step, 3), trial(row-step, 4)];  
            cur_pos =   [ trial(row, 2), trial(row, 3), trial(row, 4)]; 
            cur_gaz =   [ trial(row, 5), trial(row, 6), trial(row, 7)]; 
            delta_t =   trial(row, 1) - trial(row-step, 1);
            if(delta_t == 0)
               delta_t = 0.1; 
            end
            
            % Calculate magnitude of velocity 
            new_vel = (cur_pos - last_pos) / delta_t;
            
            % Calculate the direction of velocity in 8 discrete classes
            if(new_vel == 0)
                vel_d = NaN;
                dir_vel = NaN;
            else
                vel_d = atan(new_vel(3) / new_vel(1)) * (360/pi);
                dir_vel = ceil( mod((vel_d + 22.5)/45, nbins) );
            end
            
            % Calculate magnitude of acceleration
            new_acc = ([new_vel(1), new_vel(3)] - last_vel) / delta_t;
                   
            % Calculate the direction of acceleration in 8 discrete classes
            if(new_acc == 0)
                acc_d = NaN;
                dir_acc = NaN;
            else
                acc_d = atan(new_acc(2) / new_acc(1)) * (360/pi);
                dir_acc = ceil( mod((acc_d + 22.5)/45, nbins) );
            end
            
            % Calcluating head pose data
            gaz_d = atan(cur_gaz(3) / cur_gaz(1)) * (360/pi);
            dir_gaz = ceil( mod((gaz_d + 22.5)/45, nbins) );
            
            trial(row,8) = new_vel(1);      % vel x
            trial(row,9) = new_vel(3);      % vel y
            trial(row,10) = new_acc(1);     % acc x
            trial(row,11) = new_acc(2);     % acc y
            trial(row,12) = norm(new_vel);  % vel magnitude
            trial(row,13) = norm(new_acc);  % acc magnitude
            trial(row,14) = vel_d;          % vel angle
            trial(row,15) = acc_d;          % acc angle
            trial(row,16) = gaz_d;          % gaze angle
            trial(row,17) = dir_vel;        % vel 8-bin
            trial(row,18) = dir_acc;        % acc 8-bin
            trial(row,19) = dir_gaz;        % gaz 8-bin
        end
    end    
    writematrix(trial, [newDir file.name],'Delimiter','comma')
end

% Figures
subplot(2,3,1)
bar(trial(:,1), trial(:, 17));
title('Velocity')

subplot(2,3,2)
bar(trial(:,1), trial(:, 18));
title('Acceleration')

subplot(2,3,3)
bar(trial(:,1), trial(:, 19));
title('Gaze')

subplot(2,3,4)
stem(trial(:,1), trial(:, 14));
title('Velocity')

subplot(2,3,5)
stem(trial(:,1), trial(:, 15));
title('Acceleration')

subplot(2,3,6)
stem(trial(:,1), trial(:, 16));
title('Gaze')

quiver(trial(:,1), trial(:,4), trial(:,5), trial(:,(7)), 1);

figure;
bar(trial(:,1), trial(:, 17));
figure;
bar(trial(:,1), trial(:, 18));
figure;
bar(trial(:,1), trial(:, 19));

