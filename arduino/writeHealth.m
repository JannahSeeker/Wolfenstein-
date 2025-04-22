% write health function
function writeHealth(uno,h_p)
    greenPins = {'D4', 'D6', 'D7', 'D2', 'D9', 'D8'};  % Green LEDs (ordered)
    h_val = h_p/100;
    num_led_on = min(ceil(h_val*length(greenPins)), length(greenPins));
    % turning on required LEDs
    for i = 1: num_led_on
        writeDigitalPin(uno, greenPins{i}, 1);
    end
    % turning off unnecessary LEDs
    for i = num_led_on+1 : length(greenPins) % matlab skips the unnecessary checks
        writeDigitalPin(uno, greenPins{i}, 0);
    end
end

