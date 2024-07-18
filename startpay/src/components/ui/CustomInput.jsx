import React from 'react'

const CustomInput = ({placeholder, name, id, value, className, error, ...props}) => {
  return (
    <div>
      <input type="text" placeholder={placeholder} id={id} className={`input input-bordered w-full max-w-xs ${className}`} name={name}  {...props}/>
      {error &&  <div className="text-red-900 text-sm">{error}</div>}
    </div>
  )
}

export default CustomInput