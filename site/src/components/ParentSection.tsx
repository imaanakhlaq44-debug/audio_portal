const points = [
  ['Safe content', 'Har kahani parhi, suni aur check ki gayi hai.'],
  ['No ads, no tracking', 'Koi ishtehar nahi, koi analytics nahi.'],
  ['Parents area', '4-digit PIN ke peeche: listening stats aur settings.'],
  ['Screen-time friendly', 'Sunne wali app hai, is liye screen par nazar nahi.'],
  ['Bedtime listening', 'Sleep timer kahani ko narmi se band kar deta hai.'],
  ['Meaningful lessons', 'Har series aik akhlaqi qadar ke gird ghoomti hai.'],
];

export function ParentSection() {
  return (
    <section className="py-16 sm:py-20">
      <div className="section">
        <div className="overflow-hidden rounded-[var(--radius-xl2)] bg-navy
          px-6 py-12 text-white sm:px-12">
          <div className="grid gap-10 lg:grid-cols-2 lg:items-center">
            <div>
              <p className="inline-flex items-center gap-2 rounded-full
                bg-white/10 px-4 py-1.5 text-xs font-bold tracking-wider
                uppercase">
                Parents ke liye
              </p>
              <h2 className="mt-4 text-3xl text-white sm:text-4xl">
                Parents ke liye bhi sukoon
              </h2>
              <p className="mt-3 text-base leading-relaxed text-white/80">
                Qissora bachon ke liye bana hai, lekin walidain ke aitmaad par
                khara utarne ke liye bhi. Aap jaante hain ke aap ka bacha kya
                sun raha hai.
              </p>
            </div>

            <ul className="grid gap-4 sm:grid-cols-2">
              {points.map(([title, body]) => (
                <li key={title} className="rounded-2xl bg-white/10 p-4">
                  <h3 className="text-base text-white">{title}</h3>
                  <p className="mt-1 text-sm text-white/75">{body}</p>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
