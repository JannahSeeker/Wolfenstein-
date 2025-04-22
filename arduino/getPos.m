% main function to get position 
function [x1,y1,x2,y2,q1,q2] = getPos(nano)
    configurePin(nano,'D2','pullup');    %configured to PULLUP in Arduino Explorer
    configurePin(nano,'D3','pullup');   %configured to PULLUP in Arduino Explorer

    x1Value = readVoltage(nano, "A0"); % raw value from joystick1
    y1Value = readVoltage(nano, "A1");% raw value from joystick1
    x2Value = readVoltage(nano, "A3");% raw value from joystick2
    y2Value = readVoltage(nano, "A4");% raw value from joystick2

    
    % threshold
    high = 3;
    low = 2;
 
    
    % Set all values = 0
    x1 = 0;
    x2 = 0;
    y2 = 0;
    y1 = 0;
    q1 = 0;
    q2 = 0;

    % x1- forward and backward movement
    if x1Value > high
        x1 = 1;
    elseif x1Value < low
        x1 = -1;
    end

    % y1- strafing
    if y1Value > high
        y1 = 1;
    elseif y1Value < low
        y1 = -1;
    end

    %x2- not required
    x2 = 0;

   
    % y2 - panning around(rotation)
    if y2Value > high
        y2 = 1;
    elseif y2Value < low
        y2 = -1;
    end
    q1 = ~readDigitalPin(nano,"D2");
    q2 = ~readDigitalPin(nano,"D3");
    

end