# coding=utf-8
"""
    @project: MaxKB
    @Author：虎
    @file： embedding.py
    @date：2024/7/11 14:06
    @desc:
"""
from typing import Dict, List

import requests
from langchain_core.embeddings import Embeddings
from langchain_core.pydantic_v1 import BaseModel
from langchain_huggingface import HuggingFaceEmbeddings

from setting.models_provider.base_model_provider import MaxKBBaseModel


class WebLocalEmbedding(MaxKBBaseModel, BaseModel, Embeddings):
    @staticmethod
    def new_instance(model_type, model_name, model_credential: Dict[str, object], **model_kwargs):
        pass

    model_id: str = None

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.model_id = kwargs.get('model_id', None)

    def embed_query(self, text: str) -> List[float]:
        res = requests.post(f'http://127.0.0.1:5432/api/model/{self.model_id}/embed_query', {'text': text})
        result = res.json()
        if result.get('code', 500) == 200:
            return result.get('data')
        raise Exception(result.get('msg'))

    def embed_documents(self, texts: List[str]) -> List[List[float]]:
        res = requests.post(f'http://127.0.0.1:5432/api/model/{self.model_id}/embed_documents', {'texts': texts})
        result = res.json()
        if result.get('code', 500) == 200:
            return result.get('data')
        raise Exception(result.get('msg'))


class LocalEmbedding(MaxKBBaseModel, HuggingFaceEmbeddings):

    @staticmethod
    def new_instance(model_type, model_name, model_credential: Dict[str, object], **model_kwargs):
        if model_kwargs.get('use_local', True):
            return LocalEmbedding(model_name=model_name, cache_folder=model_credential.get('cache_folder'),
                                  model_kwargs={'device': model_credential.get('device')},
                                  encode_kwargs={'normalize_embeddings': True}
                                  )
        return WebLocalEmbedding(model_name=model_name, cache_folder=model_credential.get('cache_folder'),
                                 model_kwargs={'device': model_credential.get('device')},
                                 encode_kwargs={'normalize_embeddings': True},
                                 **model_kwargs)
