files = dir('..\..\PedestrianData\CleanData\*.txt');
newDir = '..\..\PedestrianData\IntentionData\';

step = 1;
nbins = 8;
edges = [0 45 90 135 180 225 270 315 360];

for file = files'
    trial = load("..\..\PedestrianData\CleanData\" + file.name);
    [rows, columns] = size(trial);
    for row = step:step:rows       
        % Set the first row data
        if row == step

            % Calcluating head pose data
            cur_gaz = [ trial(row, 5), trial(row, 6), trial(row, 7)]; 
            %gaz_d = (atan2d(cur_gaz(3) / cur_gaz(1)) /pi) * 180;
            gaz_d = atan2d(cur_gaz(1), cur_gaz(3));
            if gaz_d < 0
               gaz_d = gaz_d + 360; 
            end
            dir_gaz = discretize(gaz_d, edges);
            %dir_gaz = ceil( mod((gaz_d + 22.5)/45, nbins) );
            
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
            trial(row, 20) = dir_gaz;   % change 8-bin

        else
            % Set variables
            last_vel =  [ trial(row-step, 8), trial(row-step, 9) ];
            last_pos =  [ trial(row-step, 2), trial(row-step, 3), trial(row-step, 4)];  
            cur_pos =   [ trial(row, 2), trial(row, 3), trial(row, 4)]; 
            last_gaz_d = trial(row-step, 16); 
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
                %vel_d = (atan(new_vel(3) / new_vel(1)) / pi) * 180;
                vel_d = atan2d(new_vel(1), new_vel(3));
                if vel_d < 0
                   vel_d = vel_d + 360; 
                end
                dir_vel = discretize(vel_d, edges);
                %dir_vel = ceil( mod((vel_d + 22.5)/45, nbins) );
            end
            
            % Calculate magnitude of acceleration
            new_acc = ([new_vel(1), new_vel(3)] - last_vel) / delta_t;
                   
            % Calculate the direction of acceleration in 8 discrete classes
            if(new_acc == 0)
                acc_d = NaN;
                dir_acc = NaN;
            else
                %acc_d = (atan(new_acc(2) / new_acc(1)) / pi) * 180;
                acc_d = atan2d(new_acc(1), new_acc(2));
                if acc_d < 0
                   acc_d = acc_d + 360; 
                end
                dir_acc = discretize(acc_d, edges);
                %dir_acc = ceil( mod((acc_d + 22.5)/45, nbins) );
            end
            
            % Calcluating head pose data
            %gaz_d = (atan(cur_gaz(3) / cur_gaz(1)) / pi) * 180;
            gaz_d = atan2d(cur_gaz(1), cur_gaz(3));
            if gaz_d < 0
               gaz_d = gaz_d + 360; 
            end
            dir_gaz = discretize(gaz_d, edges);
            %dir_gaz = ceil( mod((gaz_d + 22.5)/45, nbins) );
            
            tmp = ceil( (gaz_d - last_gaz_d + 30) / 10);
            if (tmp < 0)
                dir_chg = 1;
            elseif (tmp > 7)
                dir_chg = 8;
            else
                dir_chg = tmp;
            end
            
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
            trial(row,20) = dir_chg;        % change 8-bin
        end
    end    
    writematrix(trial, [newDir file.name],'Delimiter','comma')
end