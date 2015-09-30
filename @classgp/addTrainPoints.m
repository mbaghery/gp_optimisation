function addTrainPoints(this, xs, ys)
  % xs is a matrix whose rows are the new training points

  this.X=[this.X; xs];
  this.Y=[this.Y; ys];
end