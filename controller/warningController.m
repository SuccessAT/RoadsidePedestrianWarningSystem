function [warningOn, state] = warningController(state, occupied, dt, cfg)
%WARNINGCONTROLLER Debounced ON/OFF logic for the roadside warning sign.
%
% state.warningOn : current sign state (logical)
% state.timer     : seconds spent in the pending transition
%
% occupied must be TRUE for triggerDelay seconds before the sign turns ON,
% and FALSE for clearDelay seconds before it turns OFF. This prevents the
% sign from flickering on a single noisy frame.

if isempty(state)
    state.warningOn = false;
    state.timer = 0;
end

if occupied
    if ~state.warningOn
        state.timer = state.timer + dt;
        if state.timer >= cfg.detectionZone.triggerDelay
            state.warningOn = true;
            state.timer = 0;
        end
    else
        state.timer = 0;   % already on, reset the (unused) clear timer
    end
else
    if state.warningOn
        state.timer = state.timer + dt;
        if state.timer >= cfg.detectionZone.clearDelay
            state.warningOn = false;
            state.timer = 0;
        end
    else
        state.timer = 0;
    end
end

warningOn = state.warningOn;

end
