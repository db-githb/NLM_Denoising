% NL-Means
function output_img = nl_means(img, swind, frame, std_dev)

% pad array to process boundary pixels
temp_size = size(img);
img_size = temp_size(1);
pic = padarray(img,[frame frame],'symmetric');

var = std_dev*std_dev; % estimation of the noise variance
output = zeros(size(pic)); % function output size

% Local Neighbourhood
kernel = make_kernel(frame, std_dev);
kernel = kernel / sum(sum(kernel));

% Loop through current neighbourhood (ni)
% which is updated with Non-Local Means
for x = 1:img_size

    % row index into local neighbourhood
    ix = x+frame;
    for y = 1:img_size

        % column index into local neighbourhood
        iy = y+frame;

        % get current neighbourhood
        ni = pic(ix-frame:ix+frame, iy-frame:iy+frame);
        
        % initialize all variables to loop through search neighbourhoods
        z=0; % non-centered weighted pixels
        cp_weight = 0; %center pixel weight
        weight_sum = 0;
        xmin = max(ix-swind,frame+1);
        xmax = min(ix+swind,frame+img_size);
        ymin = max(iy-swind,frame+1);
        ymax = min(iy+swind,frame+img_size);
        
        % loop through search neighbourhoods 
        for jx = xmin:xmax
            for jy = ymin:ymax

                % skip center pixel
                 if(jx==ix && jy==iy)
                    continue;
                 end

                 % get search neighbourhood
                 nj = pic(jx-frame:jx+frame, jy-frame:jy+frame);

                 % compute pixel weighted average of search neighbourhood
                 ndiff = ni-nj;
                 eucl_dist = ndiff.*ndiff;
                 ev = sum(sum(kernel.*eucl_dist));
                 weight = exp(-ev/var);
                
                % find Max CPW
                if weight>cp_weight                
                   cp_weight = weight;                   
                end

                % sum of the weights required for normalizing weights
                weight_sum = weight_sum + weight;

                % sum of non-centered weighted pixels
                z = z + weight*pic(jx,jy);
            end
        end
        
        % add weighted center pixel to summation
        weight_sum = weight_sum + cp_weight;
        output(ix,iy) = z + cp_weight*pic(ix,iy);
        
        % denoised pixel (weighted pixel avg.)
        output(ix,iy) = output(ix,iy)/weight_sum;
    end
end 

% slice off padding and return denoised image
output_img = output(frame+1:frame+img_size, frame+1:frame+img_size);
end

function [kernel] = make_kernel(frame, sigma)              

% ensure kernel is always of odd size
% odd size ensures center pixel
kernel=zeros(2*frame+1,2*frame+1);  

% loop sets values of the kernel
for dist=1:frame    
  if sigma<=0
  % non-gaussian exponential function
    value= 1 / (2*dist+1)^2 ;
  else
  % Guassian Kernel with sigma
    value = 1/(sqrt(2*pi)*sigma*exp(dist*dist));
  end

  % loop ensures kernel symmetry
  for x=-dist:dist
  for y=-dist:dist
    % set values of cell in kernel
    kernel(frame+1-x,frame+1-y)= kernel(frame+1-x,frame+1-y) + value ;
  end
  end
end

% average kernel and return it
kernel = kernel ./ frame;
end