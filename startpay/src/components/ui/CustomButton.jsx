import React from 'react'

const ButtonComp = ({ children, ...props }) => {
  return (
    <div>
        <button className="btn btn-xs sm:btn-sm md:btn-md lg:btn-lg" {...props}>{children}</button>
    </div>
  )
}

export default ButtonComp