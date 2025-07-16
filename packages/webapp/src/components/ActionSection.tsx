/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 16:22:15
 */

import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';

interface ActionSectionProps {
  title: string;
  placeholder: string;
  value: string;
  onChange: (value: string) => void;
  onAction: () => void;
  buttonText: string;
  variant?: 'default' | 'secondary' | 'destructive' | 'outline';
  disabled?: boolean;
}

export function ActionSection({
  title,
  placeholder,
  value,
  onChange,
  onAction,
  buttonText,
  variant = 'default',
  disabled = false,
}: ActionSectionProps) {
  return (
    <div className="space-y-2">
      <Label htmlFor={title}>{title}</Label>
      <div className="flex gap-2">
        <Input
          id={title}
          type="number"
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          className="flex-1"
        />
        <Button
          onClick={onAction}
          disabled={disabled || !value}
          variant={variant}
          className="px-6"
        >
          {buttonText}
        </Button>
      </div>
    </div>
  );
}
