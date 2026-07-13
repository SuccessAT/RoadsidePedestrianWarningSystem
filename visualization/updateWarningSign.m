function updateWarningSign(h, warningOn)
%UPDATEWARNINGSIGN Flip the sign marker color based on controller state.

if warningOn
    set(h, 'MarkerFaceColor', [1 0 0]);   % red = ON
else
    set(h, 'MarkerFaceColor', [0.7 0.7 0.7]); % grey = OFF
end

end
