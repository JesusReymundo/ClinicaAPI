using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("PacienteSeguro")]
public class PacienteSeguro
{
    [Key]
    public int IdPacienteSeguro { get; set; }
    public int IdPaciente { get; set; }
    public int IdSeguro { get; set; }
    [MaxLength(50)]
    public string? NumeroPoliza { get; set; }
    public DateOnly? FechaAfiliacion { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal? CoberturaMax { get; set; }
    public bool EsActivo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("IdPaciente")]
    public Paciente? Paciente { get; set; }
    [ForeignKey("IdSeguro")]
    public Seguro? Seguro { get; set; }
}
