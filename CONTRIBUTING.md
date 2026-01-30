# Contributing to Islamic Todo

Alhamdulillah! Thank you for your interest in contributing to Islamic Todo. This project aims to help Muslims worldwide with their daily prayers and productivity.

## 🤲 Islamic Etiquette

As this is an Islamic application, we expect all contributors to:
- Maintain Islamic values and principles
- Be respectful and courteous in all interactions
- Ensure content accuracy regarding Islamic practices
- Verify Islamic content with reliable sources

## 📋 Code of Conduct

### Our Pledge

In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to make participation in our project and our community a harassment-free experience for everyone.

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Content that contradicts Islamic teachings
- Any conduct that is unprofessional or unwelcome

## 🚀 How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Use the bug report template**
3. **Provide detailed information**:
   - Device/OS version
   - App version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

1. **Check the roadmap** in CHANGELOG.md
2. **Open a feature request issue**
3. **Describe the feature**:
   - What problem does it solve?
   - How would it work?
   - Islamic context (if applicable)
   - Mock-ups or examples (optional)

### Pull Requests

#### Before You Start

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Check existing PRs** to avoid duplicates
4. **Discuss major changes** in an issue first

#### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Islamic-Todo-App.git
cd Islamic-Todo-App

# Add upstream remote
git remote add upstream https://github.com/brahimje/Islamic-Todo-App.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

#### Code Guidelines

**Flutter/Dart Standards:**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` (should have 0 errors/warnings)
- Run `dart format .` before committing
- Add comments for complex logic
- Write self-documenting code

**Architecture:**
- Follow the existing project structure
- Use Riverpod for state management
- Keep UI code in `presentation/`
- Keep business logic in `domain/`
- Keep data models in `data/`

**Islamic Content:**
- Verify Quranic verses with reliable sources
- Include Arabic text with transliteration
- Add proper attributions for Hadith
- Consult Islamic scholars for complex rulings
- Include references for all Islamic content

**UI/UX:**
- Maintain minimalist black & white design
- Ensure accessibility
- Test on multiple screen sizes
- Keep performance in mind
- Follow Material Design guidelines

#### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add Tahajjud prayer reminder
fix: Correct Fajr time calculation in winter
docs: Update prayer time API documentation
refactor: Optimize task list rendering
test: Add tests for prayer completion
style: Format code according to Dart style guide
```

**Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code formatting (no logic change)
- `refactor:` Code restructuring (no behavior change)
- `test:` Adding or updating tests
- `chore:` Build process or auxiliary tool changes

#### Testing

- Write tests for new features
- Ensure existing tests pass: `flutter test`
- Test on real devices when possible
- Test prayer times in different locations
- Test across time zone changes

#### Pull Request Process

1. **Update documentation** if needed
2. **Add/update tests** for your changes
3. **Ensure all tests pass**
4. **Run** `flutter analyze` (0 issues)
5. **Update CHANGELOG.md** (under Unreleased)
6. **Create PR** with clear description:
   - What does this PR do?
   - Why is this change needed?
   - How has it been tested?
   - Screenshots (if UI change)
   - Islamic justification (if content change)

7. **Link related issues**: "Fixes #123"
8. **Be responsive** to review comments
9. **Update your branch** if main has changed:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

## 🎯 Priority Areas

We especially welcome contributions in:

### High Priority
- [ ] Arabic language translation
- [ ] RTL layout support
- [ ] Unit and integration tests
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Bug fixes

### Medium Priority
- [ ] Additional prayer calculation methods
- [ ] More Nafila prayer options
- [ ] Enhanced statistics
- [ ] Widget support
- [ ] Documentation improvements

### Low Priority
- [ ] UI enhancements
- [ ] Animation improvements
- [ ] Code refactoring
- [ ] Additional themes

## 📝 Islamic Content Guidelines

### Adding Quranic Content
- Use verified translations
- Include Arabic text
- Include Surah and Ayah reference
- Format: "Surah Name (Number:Ayah)"
- Example: "Al-Baqarah (2:45)"

### Adding Hadith
- Include full reference (Book, Hadith number)
- Specify authenticity (Sahih, Hasan, etc.)
- Include narrator chain if relevant
- Example: "Sahih Bukhari 1154"

### Prayer Times
- Use established calculation methods
- Document any adjustments
- Test across different locations
- Verify with local mosque times

### Duas and Adhkar
- Include Arabic text
- Add transliteration
- Add English translation
- Include source reference
- Specify recommended times

## 🔒 Security

### Reporting Security Issues

**DO NOT** open public issues for security vulnerabilities.

Instead:
1. Email: security@islamictodo.app
2. Include detailed description
3. Include steps to reproduce
4. Suggest a fix if possible

We'll respond within 48 hours.

### Security Considerations
- Never commit API keys
- Don't expose user data
- Validate all inputs
- Handle permissions securely
- Follow OWASP mobile security guidelines

## 📚 Resources

### Learning Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [Islamic Prayer Times Info](https://www.islamicfinder.org/prayer-times/)

### Islamic References
- [Quran.com](https://quran.com/)
- [Sunnah.com](https://sunnah.com/) (Hadith)
- [IslamQA](https://islamqa.info/en) (Scholarly rulings)

## 🌟 Recognition

All contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Included in app's About section (for significant contributions)

## 💬 Communication

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **Pull Requests**: Code contributions
- **Email**: For private matters

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 JazakAllahu Khairan

Thank you for contributing to Islamic Todo! May Allah reward you for your efforts in creating tools that help Muslims practice their faith.

---

**Remember**: This app is built with the intention to please Allah (SWT) and help the Muslim Ummah. Keep this intention pure in all your contributions.

**"The best of people are those who are most beneficial to people."** - Prophet Muhammad ﷺ (Sahih)
