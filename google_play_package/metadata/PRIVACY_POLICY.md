# Privacy Policy for StarWireHub

**Last updated:** November 13, 2026

StarWireHub ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains our practices regarding data collection, usage, and disclosure when you use our mobile application.

---

### 1. Information We Do NOT Collect
StarWireHub is designed with a strict privacy-first architecture:
* **No Account Required:** You do not need to register, sign in, or provide any personal identification (name, email, phone number) to use the app.
* **No Personal Tracking or Analytics:** We do not use third-party analytics SDKs, trackers, or behavioral profiling tools.
* **No Advertisements:** StarWireHub contains zero advertisements and does not integrate with any advertising networks.

---

### 2. Information Handled Locally on Your Device
The app stores certain non-personal preferences locally on your device via Android's secure `SharedPreferences`:
* **Bookmarks:** The list of repository names you choose to save for quick offline reference.
* **Font and Display Settings:** Your preferred Arabic font (Cairo, Tajawal, Almarai, or Alexandria).
* **Sync Check Cache:** A local cache of known repository identifiers used to detect when a newly published repository appears.

*None of this data is ever transmitted to us or any external servers.*

---

### 3. Network Communications & Third-Party APIs
StarWireHub communicates over encrypted HTTPS channels exclusively with public developer APIs:
* **GitHub API & Raw Content (`api.github.com`, `raw.githubusercontent.com`):** Used strictly to fetch public repository statistics (stars, forks, open issues), descriptions, and public `README.md` files. These requests are anonymous and do not contain any user personal data.

---

### 4. Notifications & Background Sync
The app includes an optional background sync service that checks the public repository index periodically (every 60 minutes) to deliver notifications about new open-source discoveries:
* **Permission:** The `POST_NOTIFICATIONS` permission is requested on Android 13 and above.
* **Local Processing:** Notifications are scheduled and generated locally on your device. No remote push server receives your device token.

---

### 5. Children's Privacy
StarWireHub does not address anyone under the age of 13, nor does it knowingly collect personal data from children.

---

### 6. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. Any changes will be posted on this page with an updated revision date.

---

### 7. Contact Us
If you have any questions or feedback regarding this Privacy Policy, please contact:
* **Project Repository:** https://github.com/boffti/starwire
* **Email:** support@starwirehub.dev

