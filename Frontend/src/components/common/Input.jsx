import React, { forwardRef } from 'react';

const Input = forwardRef(function Input({
  label,
  error,
  hint,
  icon: Icon,
  iconRight,
  className = '',
  wrapperClass = '',
  ...props
}, ref) {
  return (
    <div className={`flex flex-col gap-1 ${wrapperClass}`}>
      {label && (
        <label className="label" htmlFor={props.id || props.name}>
          {label}
          {props.required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      <div className="relative">
        {Icon && (
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">
            <Icon size={16} />
          </span>
        )}
        <input
          ref={ref}
          id={props.id || props.name}
          className={`input ${Icon ? 'pl-9' : ''} ${iconRight ? 'pr-9' : ''} ${error ? 'border-red-400 focus:border-red-400' : ''} ${className}`}
          {...props}
        />
        {iconRight && (
          <span className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400">
            {iconRight}
          </span>
        )}
      </div>
      {error && <p className="text-sm text-red-500 mt-0.5">{error}</p>}
      {hint && !error && <p className="text-xs text-slate-400 mt-0.5">{hint}</p>}
    </div>
  );
});

export default Input;
