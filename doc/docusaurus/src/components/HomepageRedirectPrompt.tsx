import React from 'react';
import clsx from 'clsx';
import styles from './HomepageRedirectPrompt.module.css';

export default function HomepageRedirectPrompt({redirectHref}): JSX.Element {
  return (
    <div className={styles.redirect_prompt}>
        <span>
            If you are not redirected automatically, follow this <a href={redirectHref}>link</a>.
        </span>
    </div>
  );
}
