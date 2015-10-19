function [x, y] = getMin(this)
%GETMINY Gives the minimum of the target values along with the training point
%   y is the minimum of the target values and x is the corresponding
%   training point.

  [y, idx] = min(this.Y);
  x = this.X(idx,:);

end

