import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './index.module.css';
import HomepageRedirectPrompt from '../components/HomepageRedirectPrompt';
import BrowserOnly from '@docusaurus/BrowserOnly';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
      </div>
    </header>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  const introPageHref = 'docs/intro'

  return (
    <Layout
      title={`${siteConfig.title}`}
      description="solid_lints documentation">
      <BrowserOnly>
        {() => <script>{window.location.href = introPageHref}</script>}
      </BrowserOnly>

      <HomepageHeader />
      <HomepageRedirectPrompt redirectHref={introPageHref}/>
    </Layout>
  );
}
