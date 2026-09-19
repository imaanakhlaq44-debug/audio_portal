import { StoryCard } from '@/components/StoryCard';
import type { Series } from '@/data/types';

export function StoryGrid({ series }: { series: Series[] }) {
  return (
    <ul className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
      {series.map((s) => (
        <li key={s.id} className="h-full">
          <StoryCard series={s} />
        </li>
      ))}
    </ul>
  );
}
