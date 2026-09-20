import type { Caption } from '@/data/types';

/**
 * Which line is being spoken — and, in the silences between lines, the line
 * that was. The timings have real gaps in them (episode one of Adam says
 * nothing between 5.1s and 7.7s), and a highlight that blinks out for two
 * seconds at a time reads as a fault rather than a pause.
 *
 * Returns -1 only before the very first line begins.
 */
export function spokenIndex(captions: Caption[], positionMs: number) {
  let found = -1;
  for (let i = 0; i < captions.length; i++) {
    if (captions[i].startMs > positionMs) break;
    found = i;
  }
  return found;
}
