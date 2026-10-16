import React from 'react';

export interface LogoIconProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  className?: string;
  variant?: 'icon' | 'full' | 'white';
}

export const LogoIcon: React.FC<LogoIconProps> = ({
  className = 'h-8 w-auto',
  variant = 'icon',
  alt = 'Kirana AI',
  ...props
}) => {
  const src = variant === 'white' ? '/logo-white.png' : variant === 'full' ? '/logo.png' : '/logo-icon.png';
  return (
    <img
      src={src}
      alt={alt}
      className={`object-contain ${className}`}
      {...props}
    />
  );
};

export default LogoIcon;
