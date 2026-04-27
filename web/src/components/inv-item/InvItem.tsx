import React from 'react';

type Props = {
  children?: React.ReactNode;
  image?: string;
  label?: string;
  count?: number;
};

const InvItem: React.FC<Props> = ({ children, image, label, count }) => {
  return (
    <div className="bg-invitem w-16 h-16 xl:w-18 xl:h-18 2xl:w-24 2xl:h-24 relative overflow-hidden rounded-sm border border-white/5">
      {image ? (
        <img className="inv-item-image" src={image} alt={label || 'item'} />
      ) : (
        children
      )}
      {typeof count === 'number' && count > 1 && (
        <div className="inv-item-count">{count}</div>
      )}
    </div>
  );
};

export default InvItem;
