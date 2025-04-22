%function to write the leds.
% main function to get position 
function writeKG(uno,g_p,b_p)
    % LED pin mappings
    redPin = 'D3';    % PWM Red LED
    bluePin = 'D4';   % ON/OFF Blue LED
    g_val = g_p/100;
    b_val = b_p/100;
    writePWMDutyCycle(uno, redPin, b_val);
    writePWMDutyCycle(uno, bluePin, g_val);

end