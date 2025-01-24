#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
from datetime import datetime


# # 数据预处理

# In[2]:


# 加载数据
medals_df = pd.read_csv('./2025_Problem_C_Data/summerOly_medal_counts.csv', encoding='ISO-8859-1')
hosts_df = pd.read_csv('./2025_Problem_C_Data/summerOly_hosts.csv')
programs_df = pd.read_csv('./2025_Problem_C_Data/summerOly_programs.csv', encoding='ISO-8859-1')
athletes_df = pd.read_csv('./2025_Problem_C_Data/summerOly_athletes.csv', encoding='ISO-8859-1')

# 查看数据结构，确保正确加载
print(medals_df.head())
print(hosts_df.head())
print(programs_df.head())
print(athletes_df.head())


# In[3]:


# 检查缺失值
print(medals_df.isnull().sum())
print(hosts_df.isnull().sum())
print(programs_df.isnull().sum())
print(athletes_df.isnull().sum())

# 如果存在缺失值，根据情况填补或删除
medals_df.dropna(subset=['Gold', 'Silver', 'Bronze', 'Total'], inplace=True)
athletes_df.dropna(subset=['Name', 'Team', 'Medal'], inplace=True)


# In[5]:


# 将年份列转换为整数类型
medals_df['Year'] = medals_df['Year'].astype(int)
hosts_df['Year'] = hosts_df['Year'].astype(int)
athletes_df['Year'] = athletes_df['Year'].astype(int)

# 将奖牌数量转换为整数类型
medals_df['Gold'] = medals_df['Gold'].astype(int)
medals_df['Silver'] = medals_df['Silver'].astype(int)
medals_df['Bronze'] = medals_df['Bronze'].astype(int)
medals_df['Total'] = medals_df['Total'].astype(int)


# In[6]:


# 合并奖牌数据和运动员数据
merged_df = pd.merge(athletes_df, medals_df, how='left', left_on=['NOC', 'Year'], right_on=['NOC', 'Year'])

# 检查合并后的数据
print(merged_df.head())


# # 特征工程

# In[8]:


# 在hosts_df中为每个年份的主办国创建一个东道主标记
hosts_df['Host'] = 1  # 主办国标记为1

# 合并东道主信息
merged_df = pd.merge(merged_df, hosts_df[['Year', 'Host']], how='left', on='Year')

# 如果没有主办国信息，则填充为0（不是东道主）
merged_df['Host'].fillna(0, inplace=True)

# 检查更新后的数据
print(merged_df.head())


# In[9]:


# 为运动员创建一个新的列，表示奖牌类型
merged_df['Medal_Type'] = np.where(merged_df['Medal'] == 'Gold', 'Gold',
                                   np.where(merged_df['Medal'] == 'Silver', 'Silver',
                                            np.where(merged_df['Medal'] == 'Bronze', 'Bronze', 'No Medal')))

# 检查创建的奖牌类型列
print(merged_df[['Name', 'Medal_Type']].head())


# In[11]:


# 计算国家的奖牌增速（例如金牌数量变化）
medals_df['Gold_Change'] = medals_df.groupby('NOC')['Gold'].pct_change()  # 使用百分比变化

# 如果是首次参加奥运会，设置增速为0
medals_df['Gold_Change'].fillna(0, inplace=True)

# 检查添加的增速特征
print(medals_df[['NOC', 'Year', 'Gold_Change']].head())


# In[ ]:


# # 保存清洗后的数据
# merged_df.to_csv('cleaned_olympic_data.csv', index=False)


# In[12]:


import matplotlib.pyplot as plt
import seaborn as sns

# 假设我们分析的是2024年奥运会金牌数量的排名
year = 2024
top_n = 20  # 显示排名前20的国家

# 筛选数据
medals_2024 = medals_df[medals_df['Year'] == year]
medals_2024_sorted = medals_2024.sort_values(by='Gold', ascending=False).head(top_n)

# 绘制条形图
plt.figure(figsize=(10, 6))
sns.barplot(x='Gold', y='NOC', data=medals_2024_sorted, palette='viridis')
plt.title(f'Top {top_n} Countries by Gold Medals in {year} Olympics')
plt.xlabel('Gold Medals')
plt.ylabel('Country')
plt.show()


# In[13]:


# 假设我们分析的是2024年奥运会的奖牌分布
medals_2024 = medals_df[medals_df['Year'] == 2024]
medals_2024_sorted = medals_2024.sort_values(by='Total', ascending=False).head(top_n)

# 堆叠条形图，显示金、银、铜奖牌比例
fig, ax = plt.subplots(figsize=(10, 6))
medals_2024_sorted.set_index('NOC')[['Gold', 'Silver', 'Bronze']].plot(kind='barh', stacked=True, ax=ax, color=['gold', 'silver', 'brown'])
plt.title(f'Top {top_n} Countries by Medal Count in {year} Olympics')
plt.xlabel('Number of Medals')
plt.ylabel('Country')
plt.show()


# In[15]:


# 假设我们分析的是某个国家（例如美国）的奖牌数量变化趋势
country = 'United States'

# 筛选数据
usa_medals = medals_df[medals_df['NOC'] == country]

# 绘制折线图
plt.figure(figsize=(10, 6))
plt.plot(usa_medals['Year'], usa_medals['Gold'], label='Gold', marker='o')
plt.plot(usa_medals['Year'], usa_medals['Total'], label='Total Medals', marker='o')
plt.title(f'{country} Medal Trend Over Time')
plt.xlabel('Year')
plt.ylabel('Number of Medals')
plt.legend()
plt.grid(True)
plt.show()


# In[17]:


# 假设我们分析的是2024年奥运会的不同项目奖牌分布
year = 2024
projects = merged_df[merged_df['Year'] == year]

# 按照项目和奖牌类型进行汇总
project_medals = projects.groupby(['Sport', 'Medal_Type']).size().unstack(fill_value=0)

# 绘制堆叠条形图
project_medals.plot(kind='barh', stacked=True, figsize=(12, 8), color=['gold', 'silver', 'brown'])
plt.title(f'Medal Distribution by Sport in {year} Olympics')
plt.xlabel('Number of Medals')
plt.ylabel('Sport')
plt.show()


# In[23]:


# 计算每个国家金牌的增量（即每届奥运会金牌数的差值）
medals_df['Gold_Increment'] = medals_df.groupby('NOC')['Gold'].diff()

# 按照增量排序，并展示前10名
top_increment_countries = medals_df.groupby('NOC').agg({'Gold_Increment': 'mean'}).sort_values(by='Gold_Increment', ascending=False).head(10)

# 绘制柱状图
plt.figure(figsize=(10, 6))
sns.barplot(x=top_increment_countries.index, y=top_increment_countries['Gold_Increment'], palette='coolwarm')
plt.title('Top 10 Countries with the Highest Gold Medal Increment')
plt.xlabel('Country')
plt.ylabel('Gold Medal Increment')
plt.xticks(rotation=45)
plt.show()


# # 构建模型

# In[25]:


from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import pandas as pd

# 假设我们已经有了清洗过的数据
# 将'Gold'作为目标变量（即我们要预测的变量）
# 创建一些基本特征，如奖牌数量、金牌增量、是否是东道主等

# 示例：创建一个简单的特征集
features = medals_df[['Year', 'Gold', 'Silver', 'Bronze', 'Total', 'Host']]
target = medals_df['Gold']  # 目标变量：金牌数

# 处理年份数据，转换成数值
features['Year'] = features['Year'].astype(int)

# 填充缺失值
features.fillna(0, inplace=True)
target.fillna(0, inplace=True)

# 数据标准化
scaler = StandardScaler()
scaled_features = scaler.fit_transform(features)

# 将数据划分为训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(scaled_features, target, test_size=0.2, random_state=42)


# In[ ]:


# 初始化线性回归模型
lr_model = LinearRegression()

# 训练模型
lr_model.fit(X_train, y_train)

# 预测测试集
y_pred_lr = lr_model.predict(X_test)

