FROM python:3.8
RUN pip install virtualenv
ENV VIRTUAL_ENV=/venv
RUN virtualenv $VIRTUAL_ENV -p python3
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
WORKDIR /app
ADD . /app

# Upgrade pip/setuptools/wheel and pre-install compatible wheels to avoid compiling from source
RUN pip install --upgrade pip setuptools==59.6.0 wheel
RUN pip install "spacy>=2.3.0,<3.0.0" "scikit-learn==0.22.2.post1"

# Install dependencies
RUN pip install -r requirements.txt
# Expose port
ENV PORT=8080
# Run the application
CMD ["gunicorn", "app:app", "--config=config.py"]
