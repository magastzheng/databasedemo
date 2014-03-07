/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases v6.3.2                     */
/* Target DBMS:           MS SQL Server 2005                              */
/* Project file:          MR.dez                                          */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database creation script                        */
/* Created on:            2013-10-23 17:57                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Tables                                                                 */
/* ---------------------------------------------------------------------- */

/* ---------------------------------------------------------------------- */
/* Add table "FailedConversion"                                           */
/* ---------------------------------------------------------------------- */

CREATE TABLE [dbo].[FailedConversion] (
    [FailedConversionID] INTEGER IDENTITY(0,1) NOT NULL,
    [UserID] INTEGER NOT NULL,
    [TimeCreated] DATETIME CONSTRAINT [DEF_FailedConversion_TimeCreated] DEFAULT GETUTCDATE() NOT NULL,
    CONSTRAINT [PK_FailedConversion] PRIMARY KEY ([FailedConversionID])
)
GO


CREATE NONCLUSTERED INDEX [IDX_FailedConversion_1] ON [dbo].[FailedConversion] ([UserID],[TimeCreated])
GO


/* ---------------------------------------------------------------------- */
/* Add table "FailedConversionInvestment"                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE [dbo].[FailedConversionInvestment] (
    [FailedConversionID] INTEGER NOT NULL,
    [SecID] NVARCHAR(10) NOT NULL,
    [InvestmentName] NVARCHAR(100) NOT NULL,
    [InvestmentType] NVARCHAR(40) NOT NULL,
    [Reason] NVARCHAR(100) NOT NULL,
    [InvestmentListName] NVARCHAR(100) NOT NULL
)
GO


/* ---------------------------------------------------------------------- */
/* Foreign key constraints                                                */
/* ---------------------------------------------------------------------- */

ALTER TABLE [dbo].[FailedConversionInvestment] ADD CONSTRAINT [FailedConversion_FailedConversionInvestment] 
    FOREIGN KEY ([FailedConversionID]) REFERENCES [dbo].[FailedConversion] ([FailedConversionID]) ON DELETE CASCADE
GO

