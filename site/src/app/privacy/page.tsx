import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description:
    'Qissora ki privacy policy: website par koi account nahi, koi ads ' +
    'nahi aur koi tracking nahi.',
  alternates: { canonical: '/privacy' },
};

export default function PrivacyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Privacy"
        title="Privacy Policy"
        lead="Yeh policy qissora.app website ke liye hai. App ki apni policy app ke andar aur Google Play par mojood hai."
      />
      <Prose>
        <p>
          <strong>Effective date:</strong> 20 September 2026
          <br />
          <strong>Publisher:</strong> Imaan and Akhlaq Talks (Private) Limited,
          Islamabad, Pakistan
        </p>

        <h2>The short version</h2>
        <p>
          Is website par koi account nahi banta, koi ishtehar nahi hai aur koi
          advertising ya analytics tracker nahi lagaya gaya. Hum aap se koi
          zaati maloomat nahi maangte.
        </p>

        <h2>What we collect</h2>
        <ul>
          <li>
            <strong>Koi cookies nahi.</strong> Website aap ke browser mein
            kuch store nahi karti.
          </li>
          <li>
            <strong>Koi analytics nahi.</strong> Hum aap ke visits ko track
            nahi karte.
          </li>
          <li>
            <strong>Koi forms nahi.</strong> Rabta WhatsApp ya email se hota
            hai, jo aap khud shuru karte hain.
          </li>
        </ul>

        <h2>Hosting and audio</h2>
        <p>
          Website Cloudflare Pages par hosted hai aur kahaniyon ki audio
          Cloudflare par mojood hai. Har website ki tarah, hosting provider
          technical logs rakh sakta hai, jaise IP address aur request ka waqt,
          taake service chalti rahe aur mehfooz rahe. Yeh logs hum marketing
          ke liye istemal nahi karte.
        </p>

        <h2>Children</h2>
        <p>
          Qissora bachon ke liye bana hai. Is website par bachon se koi zaati
          maloomat nahi maangi jati aur na hi jama ki jati hai.
        </p>

        <h2>The app</h2>
        <p>
          Qissora app mein listening progress, favourites aur parents PIN sirf
          phone par mehfooz hote hain. Premium subscription Google Play ke
          zariye chalti hai, aur walidain ka Google sign-in sirf subscription
          ko account se jorne ke liye hota hai. Tafseel app ki privacy policy
          mein hai.
        </p>

        <h2>Contact</h2>
        <p>
          Koi sawal ho to{' '}
          <a href={`mailto:${contact.email}`}>{contact.email}</a> par email
          karein ya{' '}
          <a href={contact.whatsappUrl}>WhatsApp {contact.whatsappDisplay}</a>{' '}
          par message karein.
        </p>
      </Prose>
    </>
  );
}
